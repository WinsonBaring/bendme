#include <metal_stdlib>
using namespace metal;

struct Raster { float4 position [[position]]; float2 uv; };
struct Parameters { float progress; float perspective; float blur; float shadow; float style; };

vertex Raster foldVertex(uint id [[vertex_id]]) {
    const float2 positions[] = {float2(-1,-1), float2(1,-1), float2(-1,1), float2(1,1)};
    Raster out;
    out.position = float4(positions[id], 0, 1);
    out.uv = float2((positions[id].x + 1) * 0.5, (1 - positions[id].y) * 0.5);
    return out;
}

fragment float4 foldFragment(Raster in [[stage_in]], texture2d<float> desktop [[texture(0)]],
                             texture2d<float> soft [[texture(1)]], texture2d<float> medium [[texture(2)]],
                             texture2d<float> strong [[texture(3)]],
                             constant Parameters &p [[buffer(0)]]) {
    constexpr sampler linearSampler(filter::linear, address::clamp_to_edge);
    float bend = clamp(p.progress, 0.0f, 1.0f);
    float rotation = bend * p.perspective * 1.22;
    float height = cos(rotation);
    float depth = sin(rotation) * 0.48;
    float fromBottom = 1 - in.uv.y;
    float denominator = height - fromBottom * depth;
    if (denominator <= 0.0001) return float4(0, 0, 0, 1);
    float v = fromBottom / denominator;
    float u = (in.uv.x - 0.5) * (1 + v * depth) + 0.5;
    if (u < 0 || u > 1 || v < 0 || v > 1) return float4(0, 0, 0, 1);
    float2 uv = float2(u, 1 - v);
    float frost = p.style > 1.5 ? 1.55 : 1.0;
    // Interpolate Gaussian scales: progressively softer near the raised edge,
    // with no sparse-kernel ghosting around text or bright points.
    float radius = clamp(bend * p.blur * frost * pow(v, 1.7), 0.0f, 1.0f) * 3;
    float4 color;
    if (radius < 1) color = mix(desktop.sample(linearSampler, uv), soft.sample(linearSampler, uv), radius);
    else if (radius < 2) color = mix(soft.sample(linearSampler, uv), medium.sample(linearSampler, uv), radius - 1);
    else color = mix(medium.sample(linearSampler, uv), strong.sample(linearSampler, uv), radius - 2);
    float shadowStrength = p.style > 0.5 && p.style < 1.5 ? 1.5 : 0.65;
    color.rgb *= 1 - bend * p.shadow * shadowStrength * pow(v, 2.0) * 0.72;
    if (p.style > 1.5) color.rgb = mix(color.rgb, float3(0.87, 0.91, 0.97), bend * p.blur * v * 0.16);
    float feather = max(0.00001, bend * 0.055);
    float edge = smoothstep(0.0, feather, 1 - v);
    edge *= smoothstep(0.0, feather * v * 0.3 + 0.00001, min(u, 1 - u));
    return float4(color.rgb * edge, 1);
}
