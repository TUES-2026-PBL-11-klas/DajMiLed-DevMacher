// app.jsx — DevMatch shell: routing, nav, apply/match logic, tweaks
const { useState: aUseState, useEffect: aUseEffect } = React;

const TWEAK_DEFAULTS = /*EDITMODE-BEGIN*/{
  "cardStyle": "accent",
  "applyFlow": "tap",
  "onboardFlow": "chat",
  "accent": "#10B981"
}/*EDITMODE-END*/;

const ACCENTS = {
  "#10B981": { soft: "#E7F7F0", ink: "#047857" },
  "#3B82F6": { soft: "#E7F0FE", ink: "#1D4ED8" },
  "#8B5CF6": { soft: "#F0EAFE", ink: "#6D28D9" },
  "#F97316": { soft: "#FEEEE0", ink: "#C2410C" },
};

function makeMatch(item) {
  const isTask = item.kind === 'task';
  return {
    id: 'new_' + item.id, name: isTask ? item.owner : item.name,
    avatar: isTask ? item.ownerAvatar : item.avatar,
    context: isTask ? `${item.project} · ${item.category}` : `You liked · ${item.role.split(' · ')[0]}`,
    unread: 0, time: 'now', preview: 'You matched! Say hi 👋', accepted: true,
    thread: [{ from: 'them', text: `You matched! Say hi 👋`, time: 'now' }],
  };
}

function isMatch(item) {
  if (item.kind === 'task') return item.match >= 80;
  return ['p_alex', 'p_yana', 'p_noa'].includes(item.id);
}

function App() {
  const [t, setTweak] = useTweaks(TWEAK_DEFAULTS);
  const [screen, setScreen] = aUseState('welcome'); // welcome | auth | onboarding | app
  const [authMode, setAuthMode] = aUseState('signup');
  const [tab, setTab] = aUseState('discover');
  const [mode, setMode] = aUseState('tasks');
  const [overlay, setOverlay] = aUseState(null); // {type:'detail',item} | {type:'chat',match} | {type:'post'}
  const [matchModal, setMatchModal] = aUseState(null);
  const [toast, setToast] = aUseState(null);
  const [applications, setApplications] = aUseState([]);
  const [matches, setMatches] = aUseState(DM.MATCHES);
  const [profile, setProfile] = aUseState({ name: '', email: '', password: '', role: '', headline: '', skills: [], goals: [], avail: '' });

  const patchP = (p) => setProfile(prev => ({ ...prev, ...p }));

  // accent → CSS vars
  aUseEffect(() => {
    const a = ACCENTS[t.accent] || ACCENTS['#10B981'];
    const r = document.documentElement.style;
    r.setProperty('--accent', t.accent);
    r.setProperty('--accent-soft', a.soft);
    r.setProperty('--accent-ink', a.ink);
  }, [t.accent]);

  const fireToast = (data) => { setToast({ ...data, key: Date.now() }); };
  aUseEffect(() => { if (!toast) return; const id = setTimeout(() => setToast(null), 2400); return () => clearTimeout(id); }, [toast && toast.key]);

  const applied = (item) => applications.some(a => a.id === item.id);
  const replay = () => { setOverlay(null); setMatchModal(null); setScreen('onboarding'); };
  const restart = () => { setOverlay(null); setMatchModal(null); setTab('discover'); setMode('tasks'); setApplications([]); setMatches(DM.MATCHES); setProfile({ name: '', email: '', password: '', role: '', headline: '', skills: [], goals: [], avail: '' }); setScreen('welcome'); };

  const handleApply = (item) => {
    if (!applied(item)) setApplications(prev => [{ ...item }, ...prev]);
    if (isMatch(item)) {
      const m = makeMatch(item);
      setMatches(prev => prev.some(x => x.id === m.id) ? prev : [m, ...prev]);
      setTimeout(() => setMatchModal({ item, match: m }), 380);
    } else {
      fireToast({ text: item.kind === 'task' ? 'Application sent ✦' : 'They\u2019ll see your profile', icon: 'send' });
    }
  };

  const startOnboard = (m) => { setAuthMode(m); setScreen('auth'); };

  function finishOnboard() {
    if (!profile.role) setProfile(p => ({ ...p, role: 'Full-stack Developer', skills: p.skills.length ? p.skills : ['React', 'Node.js'], goals: p.goals.length ? p.goals : ['mvp'], avail: p.avail || 'some' }));
    setScreen('app'); setTab('discover');
  }

  // ── Main app ──
  const tabScreen = () => {
    if (tab === 'discover') return <Discover mode={mode} setMode={setMode} cardStyle={t.cardStyle} applyFlow={t.applyFlow}
      onApply={(it) => handleApply(it)} onOpen={(it) => setOverlay({ type: 'detail', item: it })} toast={fireToast} />;
    if (tab === 'matches') return <Matches matches={matches} applications={applications} onOpenChat={(m) => setOverlay({ type: 'chat', match: m })} />;
    if (tab === 'profile') return <Profile profile={profile} />;
  };

  const unread = matches.reduce((n, m) => n + (m.unread || 0), 0);

  // ── Pre-app stack ──
  let body;
  if (screen === 'welcome') body = <Frame><Welcome onStart={startOnboard} /></Frame>;
  else if (screen === 'auth') body = <Frame keyboard><Auth mode={authMode} profile={profile} patch={patchP}
    onBack={() => setScreen('welcome')}
    onDone={() => authMode === 'signin' ? finishOnboard() : setScreen('onboarding')} /></Frame>;
  else if (screen === 'onboarding') body = <Frame><Onboarding flow={t.onboardFlow} profile={profile} patch={patchP}
    onBack={() => setScreen('auth')} onDone={finishOnboard} /></Frame>;
  else body = (
    <Frame>
      <div style={{ height: '100%', position: 'relative', display: 'flex', flexDirection: 'column', background: 'var(--bg)' }}>
        <div style={{ flex: 1, minHeight: 0 }}>{tabScreen()}</div>
        <BottomNav tab={tab} setTab={setTab} unread={unread} onPost={() => setOverlay({ type: 'post' })} />

        {/* overlays */}
        {overlay && overlay.type === 'detail' && (
          <Pushed><Detail item={overlay.item} applied={applied(overlay.item)}
            onBack={() => setOverlay(null)}
            onApply={(it) => { handleApply(it); }} /></Pushed>
        )}
        {overlay && overlay.type === 'chat' && (
          <Pushed><Chat match={overlay.match} onBack={() => setOverlay(null)} /></Pushed>
        )}
        {overlay && overlay.type === 'post' && (
          <Pushed><PostTask onBack={() => setOverlay(null)}
            onPublish={() => { setOverlay(null); fireToast({ text: 'Task published — candidates incoming', icon: 'rocket' }); }} /></Pushed>
        )}

        <MatchModal data={matchModal}
          onMessage={() => { const m = matchModal.match; setMatchModal(null); setTab('matches'); setOverlay({ type: 'chat', match: m }); }}
          onClose={() => setMatchModal(null)} />
        <UI.Toast toast={toast} />
      </div>
    </Frame>
  );

  return (
    <React.Fragment>
      {body}
      <DevMatchTweaks t={t} setTweak={setTweak} onReplay={replay} onRestart={restart} />
    </React.Fragment>
  );

  function Pushed({ children }) {
    return <div style={{ position: 'absolute', inset: 0, zIndex: 70, background: 'var(--bg)' }}>{children}</div>;
  }
}

// ── Bottom navigation ────────────────────────────────────────
function BottomNav({ tab, setTab, unread, onPost }) {
  const item = (key, icon, label) => {
    const on = tab === key;
    return (
      <button key={key} onClick={() => setTab(key)} style={{
        flex: 1, display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 4,
        border: 'none', background: 'none', cursor: 'pointer', padding: '4px 0', position: 'relative',
        WebkitTapHighlightColor: 'transparent',
      }}>
        <div style={{ position: 'relative' }}>
          <UI.Icon name={icon} size={25} stroke={on ? 'var(--accent)' : 'var(--ink-3)'} sw={on ? 2.2 : 1.9}
            fill={on && icon === 'heart' ? 'var(--accent)' : 'none'} />
          {key === 'matches' && unread > 0 && (
            <span style={{ position: 'absolute', top: -3, right: -6, minWidth: 16, height: 16, borderRadius: 999, background: 'var(--accent)', color: '#fff', fontSize: 10, fontWeight: 700, display: 'flex', alignItems: 'center', justifyContent: 'center', border: '2px solid #fff', fontFamily: 'var(--mono)' }}>{unread}</span>
          )}
        </div>
        <span style={{ fontSize: 11, fontWeight: 600, color: on ? 'var(--accent-ink)' : 'var(--ink-3)', fontFamily: 'var(--sans)' }}>{label}</span>
      </button>
    );
  };
  return (
    <div style={{
      flexShrink: 0, display: 'flex', alignItems: 'center', background: '#ffffffee',
      backdropFilter: 'blur(12px)', borderTop: '1px solid var(--line)',
      padding: '8px 10px 24px', gap: 4,
    }}>
      {item('discover', 'compass', 'Discover')}
      {item('matches', 'chat', 'Matches')}
      <div style={{ flex: 1, display: 'flex', justifyContent: 'center' }}>
        <button onClick={onPost} style={{
          width: 52, height: 52, borderRadius: 18, border: 'none', background: 'var(--accent)', cursor: 'pointer',
          display: 'flex', alignItems: 'center', justifyContent: 'center', marginTop: -8,
          boxShadow: '0 10px 22px -8px var(--accent)', WebkitTapHighlightColor: 'transparent',
        }}><UI.Icon name="plus" size={26} stroke="#fff" sw={2.4} /></button>
      </div>
      {item('profile', 'user', 'Profile')}
    </div>
  );
}

// ── Device frame wrapper ─────────────────────────────────────
function Frame({ children, keyboard }) {
  return (
    <div style={{ minHeight: '100vh', display: 'flex', alignItems: 'center', justifyContent: 'center', padding: 20, background: 'var(--stage)' }}>
      <IOSDevice>{children}</IOSDevice>
    </div>
  );
}

// ── Tweaks panel ─────────────────────────────────────────────
function DevMatchTweaks({ t, setTweak, onReplay, onRestart }) {
  return (
    <TweaksPanel>
      <TweakSection label="Swipe card design" />
      <TweakRadio label="Card style" value={t.cardStyle}
        options={['detailed', 'minimal', 'accent']}
        onChange={v => setTweak('cardStyle', v)} />

      <TweakSection label="Matching interaction" />
      <TweakRadio label="How applying works" value={t.applyFlow}
        options={['instant', 'confirm', 'tap']}
        onChange={v => setTweak('applyFlow', v)} />
      <TweakRow>
        <div style={{ fontSize: 11.5, color: '#8a8f98', lineHeight: 1.5, fontFamily: 'var(--mono, monospace)' }}>
          instant = swipe right sends it · confirm = swipe opens a note sheet · tap = browse, then a dedicated Apply button
        </div>
      </TweakRow>

      <TweakSection label="Onboarding flow" />
      <TweakRadio label="Profile setup" value={t.onboardFlow}
        options={['stepped', 'one-page', 'chat']}
        onChange={v => setTweak('onboardFlow', v)} />
      <TweakButton label="Replay onboarding" onClick={onReplay}>Replay ↺</TweakButton>

      <TweakSection label="Theme" />
      <TweakColor label="Accent" value={t.accent}
        options={['#10B981', '#3B82F6', '#8B5CF6', '#F97316']}
        onChange={v => setTweak('accent', v)} />
      <TweakButton label="Restart demo" onClick={onRestart}>From welcome ↺</TweakButton>
    </TweaksPanel>
  );
}

window.DevMatchTweaks = DevMatchTweaks;
window.__APP__ = App;
