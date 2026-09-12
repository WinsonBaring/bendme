import { useEffect, useState } from 'react';
import { ArrowDownToLine, ArrowUpRight, Check, ChevronDown, Code2, Laptop, LockKeyhole, Menu, X } from 'lucide-react';
import { asset, release } from './release';
import './styles.css';

const frames = [135, 90, 60, 25, 5] as const;
const styles = [
  { id: 'silk', title: 'Silk', description: 'A soft, fluid fold.' },
  { id: 'shade', title: 'Shade', description: 'A little more depth.' },
  { id: 'frost', title: 'Frost', description: 'Light through glass.' },
] as const;

function Preview() {
  const [step, setStep] = useState(2);
  const [style, setStyle] = useState<(typeof styles)[number]['id']>('silk');
  const angle = frames[step];
  useEffect(() => {
    // Five discrete GPU-rendered frames, not simulated sensor readings.
    const images = frames.map(value => {
      const image = new Image();
      image.src = asset(`images/${style}-${value}.png`);
      return image;
    });
    return () => { for (const image of images) image.onload = null; };
  }, [style]);

  return <section className="preview-section section" id="experience" aria-labelledby="preview-title">
    <div className="section-intro">
      <h2 id="preview-title">Go on. Change the angle.</h2>
      <p>A preview of the real effect. Pick a style and move the slider.</p>
    </div>
    <div className="preview-workspace">
      <div className="preview-image">
        <img src={asset(`images/${style}-${angle}.png`)} width="640" height="416" loading="lazy" alt={`${styles.find(item => item.id === style)?.title} effect at a ${angle}-degree lid angle, rendered by BendMe`} />
      </div>
      <div className="preview-controls">
        <fieldset className="style-picker"><legend className="sr-only">Preview style</legend>
          {styles.map(item => <button key={item.id} className={`style-option ${style === item.id ? 'selected' : ''}`} aria-pressed={style === item.id} onClick={() => setStyle(item.id)}>
            <span>{item.title}</span><span className="style-description">{item.description}</span>
            {style === item.id && <Check size={16} aria-hidden="true" />}
          </button>)}
        </fieldset>
        <div className="angle-label"><label htmlFor="lid-angle">Lid angle</label><output htmlFor="lid-angle" aria-live="polite">{angle}°</output></div>
        <input id="lid-angle" type="range" min="0" max="4" step="1" value={step} aria-valuetext={`${angle} degrees`} onChange={event => setStep(Number(event.target.value))} />
        <div className="angle-endpoints"><span>Open</span><span>Almost closed</span></div>
        <p className="preview-note">In the Mac app, your actual lid does the moving. This website never reads your screen.</p>
      </div>
    </div>
  </section>;
}

function Navigation() {
  const [open, setOpen] = useState(false);
  return <header className="site-header wrap">
    <a className="wordmark" href="#top" aria-label="BendMe home"><Laptop size={24} strokeWidth={1.6} aria-hidden="true" />bendme</a>
    <button className="menu-toggle" onClick={() => setOpen(!open)} aria-expanded={open} aria-controls="site-nav" aria-label={open ? 'Close navigation' : 'Open navigation'}>{open ? <X aria-hidden="true" /> : <Menu aria-hidden="true" />}</button>
    <nav id="site-nav" className={open ? 'navigation is-open' : 'navigation'} aria-label="Main navigation">
      <a href="#experience" onClick={() => setOpen(false)}>The effect</a>
      <a href="#maker" onClick={() => setOpen(false)}>Meet the maker</a>
      <a href="#download" onClick={() => setOpen(false)}>Get BendMe <ArrowDownToLine size={15} aria-hidden="true" /></a>
    </nav>
  </header>;
}

export default function App() {
  return <>
    <a className="skip-link" href="#main">Skip to content</a>
    <Navigation />
    <main id="main">
      <section className="hero wrap" id="top" aria-labelledby="hero-title">
        <div className="hero-copy">
          <p className="eyebrow">Free. Open source. Made for Mac.</p>
          <h1 id="hero-title">A little<br /><span>less flat.</span></h1>
          <p className="hero-description">Your desktop bends as you close the lid. A free Mac app by Winson Baring.</p>
          <div className="hero-actions">
            <a className="button primary" href="#download">Get BendMe <ArrowDownToLine size={18} aria-hidden="true" /></a>
            <a className="text-link" href={release.repository}>View source <ArrowUpRight size={17} aria-hidden="true" /></a>
          </div>
        </div>
        <div className="hero-art"><img src={asset('images/bendme-hero.png')} width="1536" height="1024" fetchPriority="high" alt="Product illustration of a MacBook with a warm landscape receding into its screen" /></div>
      </section>

      <div className="wrap"><Preview /></div>

      <section className="principles section wrap" aria-labelledby="principles-title">
        <h2 id="principles-title">A small app.<br />Nothing extra.</h2>
        <div className="principles-list">
          <article><LockKeyhole size={25} strokeWidth={1.5} aria-hidden="true" /><div><h3>Your screen stays yours.</h3><p>Frames stay in memory on your Mac. No recordings, accounts, analytics, or uploads.</p></div></article>
          <article><Laptop size={25} strokeWidth={1.5} aria-hidden="true" /><div><h3>On your Dock. In your menu bar.</h3><p>Open settings from the Dock, with quick controls in the menu bar. Native Swift and Metal power the effect. Pause whenever you like.</p></div></article>
          <article><Code2 size={25} strokeWidth={1.5} aria-hidden="true" /><div><h3>Free to use. Free to make yours.</h3><p>The original code is MIT-licensed. Read it, change it, or build something of your own.</p></div></article>
        </div>
      </section>

      <section className="maker section wrap" id="maker" aria-labelledby="maker-title">
        <div className="maker-image"><img src={asset('images/winson-baring.png')} width="460" height="460" loading="lazy" alt="Winson Baring, from his public GitHub profile" /></div>
        <div className="maker-copy">
          <p className="eyebrow">Meet the maker</p>
          <h2 id="maker-title">Hi, I’m Winson.</h2>
          <p className="maker-lead">I made BendMe, and I’m sharing it for free.</p>
          <p>This is an independent take on the desktop lid effect, inspired by Bendy. The code is open so you can see how it works and help make it better.</p>
          <a className="text-link" href={release.maker}>Find me on GitHub <ArrowUpRight size={18} aria-hidden="true" /></a>
          <span className="maker-signature">Winson Baring</span>
        </div>
      </section>

      <section className="download section wrap" id="download" aria-labelledby="download-title">
        <div className="download-heading"><h2 id="download-title">Make your Mac<br />a little more playful.</h2><p>Free for everyone. No subscription. No license key.</p></div>
        <div className="download-panel">
          <div className="download-title"><Laptop size={28} strokeWidth={1.5} aria-hidden="true" /><div><h3>BendMe for Mac</h3><p>Apple silicon · macOS 14 or later</p></div></div>
          <a className="button primary full-width" href={release.download}>Download DMG <ArrowDownToLine size={18} aria-hidden="true" /></a>
          <p className="release-notice">The included app is Developer ID signed and notarized by Apple. This is a free direct download; an App Store release is still being prepared.</p>
          <a className="text-link" href={`${release.repository}#build-from-source`}>Build from source <ArrowUpRight size={16} aria-hidden="true" /></a>
          <p className="requirements">The live effect requires a compatible MacBook lid sensor and Screen Recording permission. Manual preview works without either.</p>
        </div>
      </section>

      <section className="help section wrap" id="help" aria-labelledby="help-title">
        <h2 id="help-title">A few things to know.</h2>
        <div className="questions">
          <details><summary>How do I start the effect?<ChevronDown size={18} aria-hidden="true" /></summary><p>Open BendMe, choose Allow Screen Recording, and approve Apple's request. Reopen BendMe if macOS asks, then click Start BendMe. Appearance opens automatically so you can choose your style. The app starts paused each time.</p></details>
          <details><summary>Will it work with my MacBook?<ChevronDown size={18} aria-hidden="true" /></summary><p>The download supports Apple silicon and macOS 14 or later. The live effect needs a compatible lid-angle sensor; it has been verified on an M3 Pro MacBook. Sensor availability varies by model. The manual preview remains available on unsupported hardware.</p></details>
          <details><summary>How do I pause it?<ChevronDown size={18} aria-hidden="true" /></summary><p>Click Pause BendMe in Appearance, or choose Pause effect from BendMe’s menu-bar icon. Closing the lid normally can still put your Mac to sleep.</p></details>
          <details><summary>Is it on the Mac App Store?<ChevronDown size={18} aria-hidden="true" /></summary><p>Not yet. An App Store release is being prepared and must pass Apple’s signing and review requirements. The development preview and source code are available here for free.</p></details>
          <details><summary>Something isn’t working. Where can I get help?<ChevronDown size={18} aria-hidden="true" /></summary><p>Check the <a href={`${release.repository}/blob/main/SETUP.md`}>setup and troubleshooting guide</a>, or <a href={release.issues}>open a GitHub issue</a> with your Mac model, macOS version, and what happened. Don’t include private screen contents or credentials.</p></details>
        </div>
      </section>

      <section className="privacy wrap" id="privacy" aria-labelledby="privacy-title">
        <h2 id="privacy-title">Your privacy, plainly.</h2>
        <p>BendMe reads the lid angle and processes live screen frames locally to draw the effect. It doesn’t save, collect, or transmit those frames. Appearance settings are stored on your Mac. There is no account, telemetry, or advertising. Optional diagnostic images contain only BendMe’s built-in artwork.</p>
        <p>This website uses no analytics, cookies, forms, or third-party embeds. GitHub hosts the site, downloads, and source code; its infrastructure may process request information under <a href="https://docs.github.com/en/site-policy/privacy-policies/github-general-privacy-statement">GitHub’s privacy statement</a>. Public issues are visible to other people.</p>
      </section>
    </main>
    <footer className="footer wrap"><span className="wordmark"><Laptop size={22} strokeWidth={1.5} aria-hidden="true" />bendme</span><p>Made by <a href={release.maker}>Winson Baring</a>.</p><div><a href={release.license}>MIT license</a><a href="#privacy">Privacy</a><a href={release.repository} aria-label="BendMe on GitHub"><Code2 size={21} aria-hidden="true" /></a></div><p className="attribution">Inspired by <a href="https://trybendy.app">Bendy</a>. Independent and unaffiliated.</p></footer>
  </>;
}
