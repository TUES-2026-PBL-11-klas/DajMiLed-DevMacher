// onboarding.jsx — Welcome, Sign up, and 3 profile-creation flow variants
const { useState: oUseState, useRef: oUseRef, useEffect: oUseEffect } = React;

// ── Shared pickers (used by every onboarding flow) ───────────
function RolePicker({ profile, patch }) {
  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: 14 }}>
      <div style={{ display: 'flex', flexWrap: 'wrap', gap: 9 }}>
        {DM.ROLES.map(r => {
          const on = profile.role === r;
          return (
            <button key={r} onClick={() => patch({ role: r })} style={{
              padding: '11px 15px', borderRadius: 14, cursor: 'pointer',
              border: `1.5px solid ${on ? 'var(--accent)' : 'var(--line)'}`,
              background: on ? 'var(--accent-soft)' : '#fff',
              color: on ? 'var(--accent-ink)' : 'var(--ink)',
              fontWeight: 600, fontSize: 14.5, fontFamily: 'var(--sans)',
              transition: 'all .15s', WebkitTapHighlightColor: 'transparent',
            }}>{r}</button>
          );
        })}
      </div>
      <div>
        <input value={profile.headline} onChange={e => patch({ headline: e.target.value })}
          placeholder="Add a one-line headline (optional)"
          style={{
            width: '100%', boxSizing: 'border-box', padding: '14px 16px',
            border: '1.5px solid var(--line)', borderRadius: 14, fontSize: 15,
            fontFamily: 'var(--sans)', color: 'var(--ink)', outline: 'none',
          }}
          onFocus={e => e.target.style.borderColor = 'var(--accent)'}
          onBlur={e => e.target.style.borderColor = 'var(--line)'} />
      </div>
    </div>
  );
}

function SkillPicker({ profile, patch }) {
  const [q, setQ] = oUseState('');
  const sel = profile.skills;
  const toggle = (s) => patch({ skills: sel.includes(s) ? sel.filter(x => x !== s) : [...sel, s] });
  const list = DM.ALL_SKILLS.filter(s => s.toLowerCase().includes(q.toLowerCase()));
  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: 14 }}>
      <div style={{ position: 'relative' }}>
        <span style={{ position: 'absolute', left: 14, top: '50%', transform: 'translateY(-50%)', color: 'var(--ink-3)' }}>
          <UI.Icon name="search" size={18} /></span>
        <input value={q} onChange={e => setQ(e.target.value)} placeholder="Search skills…"
          style={{
            width: '100%', boxSizing: 'border-box', padding: '13px 16px 13px 42px',
            border: '1.5px solid var(--line)', borderRadius: 14, fontSize: 15,
            fontFamily: 'var(--sans)', outline: 'none',
          }}
          onFocus={e => e.target.style.borderColor = 'var(--accent)'}
          onBlur={e => e.target.style.borderColor = 'var(--line)'} />
      </div>
      {sel.length > 0 && (
        <div style={{ display: 'flex', flexWrap: 'wrap', gap: 7 }}>
          {sel.map(s => (
            <button key={s} onClick={() => toggle(s)} style={{
              display: 'inline-flex', alignItems: 'center', gap: 6, padding: '7px 10px 7px 12px',
              borderRadius: 999, border: 'none', background: 'var(--accent)', color: '#fff',
              fontFamily: 'var(--mono)', fontSize: 13, fontWeight: 500, cursor: 'pointer',
            }}>{s}<UI.Icon name="x" size={13} stroke="#fff" sw={2.4} /></button>
          ))}
        </div>
      )}
      <div style={{ display: 'flex', flexWrap: 'wrap', gap: 7 }}>
        {list.filter(s => !sel.includes(s)).slice(0, 18).map(s => (
          <button key={s} onClick={() => toggle(s)} style={{
            padding: '7px 12px', borderRadius: 999, cursor: 'pointer',
            border: '1.5px solid var(--line)', background: '#fff', color: 'var(--ink-2)',
            fontFamily: 'var(--mono)', fontSize: 13, fontWeight: 500,
            WebkitTapHighlightColor: 'transparent',
          }}>+ {s}</button>
        ))}
      </div>
    </div>
  );
}

function GoalPicker({ profile, patch }) {
  const sel = profile.goals;
  const toggle = (id) => patch({ goals: sel.includes(id) ? sel.filter(x => x !== id) : [...sel, id] });
  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: 10 }}>
      {DM.GOALS.map(g => {
        const on = sel.includes(g.id);
        return (
          <button key={g.id} onClick={() => toggle(g.id)} style={{
            display: 'flex', alignItems: 'center', gap: 14, textAlign: 'left',
            padding: '15px 16px', borderRadius: 16, cursor: 'pointer',
            border: `1.5px solid ${on ? 'var(--accent)' : 'var(--line)'}`,
            background: on ? 'var(--accent-soft)' : '#fff', transition: 'all .15s',
            WebkitTapHighlightColor: 'transparent',
          }}>
            <span style={{ fontSize: 22, lineHeight: 1 }}>{g.emoji}</span>
            <span style={{ flex: 1, fontWeight: 600, fontSize: 15, color: 'var(--ink)' }}>{g.label}</span>
            <span style={{
              width: 22, height: 22, borderRadius: 999, flexShrink: 0,
              border: `2px solid ${on ? 'var(--accent)' : 'var(--line)'}`,
              background: on ? 'var(--accent)' : '#fff',
              display: 'flex', alignItems: 'center', justifyContent: 'center',
            }}>{on && <UI.Icon name="check" size={13} stroke="#fff" sw={3} />}</span>
          </button>
        );
      })}
    </div>
  );
}

function AvailPicker({ profile, patch }) {
  return (
    <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 10 }}>
      {DM.AVAIL.map(a => {
        const on = profile.avail === a.id;
        return (
          <button key={a.id} onClick={() => patch({ avail: a.id })} style={{
            display: 'flex', flexDirection: 'column', gap: 4, textAlign: 'left',
            padding: '16px', borderRadius: 16, cursor: 'pointer',
            border: `1.5px solid ${on ? 'var(--accent)' : 'var(--line)'}`,
            background: on ? 'var(--accent-soft)' : '#fff', transition: 'all .15s',
            WebkitTapHighlightColor: 'transparent',
          }}>
            <span style={{ fontWeight: 700, fontSize: 16, color: on ? 'var(--accent-ink)' : 'var(--ink)' }}>{a.label}</span>
            <span style={{ fontFamily: 'var(--mono)', fontSize: 12, color: 'var(--ink-3)' }}>{a.sub}</span>
          </button>
        );
      })}
    </div>
  );
}

const Q = [
  { key: 'role', q: "What's your main role?", sub: 'Pick the hat you wear most. You can add more later.',
    valid: p => !!p.role, render: (p, patch) => <RolePicker profile={p} patch={patch} /> },
  { key: 'skills', q: 'What are your skills?', sub: 'Add the tags that describe what you build. Matching runs on these.',
    valid: p => p.skills.length >= 1, render: (p, patch) => <SkillPicker profile={p} patch={patch} /> },
  { key: 'goals', q: "What are you here for?", sub: 'Choose all that apply.',
    valid: p => p.goals.length >= 1, render: (p, patch) => <GoalPicker profile={p} patch={patch} /> },
  { key: 'avail', q: 'How much time do you have?', sub: 'Be honest — it sets expectations with teams.',
    valid: p => !!p.avail, render: (p, patch) => <AvailPicker profile={p} patch={patch} /> },
];

// ── Welcome ──────────────────────────────────────────────────
function Welcome({ onStart }) {
  return (
    <div style={{ height: '100%', display: 'flex', flexDirection: 'column', background: 'var(--bg)' }}>
      <div style={{ flex: 1, display: 'flex', flexDirection: 'column', justifyContent: 'center', padding: '0 30px' }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: 11, marginBottom: 30 }}>
          <Logo size={42} />
          <span style={{ fontSize: 26, fontWeight: 800, letterSpacing: '-0.03em', color: 'var(--ink)' }}>DevMatch</span>
        </div>
        <h1 style={{
          fontSize: 40, lineHeight: 1.04, fontWeight: 800, letterSpacing: '-0.035em',
          color: 'var(--ink)', margin: '0 0 16px', textWrap: 'balance',
        }}>Find the teammates your project is missing.</h1>
        <p style={{ fontSize: 16.5, lineHeight: 1.5, color: 'var(--ink-2)', margin: 0, maxWidth: 320 }}>
          Swipe through real tasks and developers. Match on skills, build something together.
        </p>
        <div style={{ marginTop: 26, display: 'flex', gap: 8, flexWrap: 'wrap' }}>
          {['Java', 'React', 'Flutter', 'Figma', 'Docker'].map(s => <UI.Tag key={s} tone="outline">{s}</UI.Tag>)}
        </div>
      </div>
      <div style={{ padding: '0 24px 40px', display: 'flex', flexDirection: 'column', gap: 11 }}>
        <UI.Btn full onClick={() => onStart('signup')} icon="sparkle">Create your profile</UI.Btn>
        <UI.Btn full variant="outline" onClick={() => onStart('signin')}>I already have an account</UI.Btn>
      </div>
    </div>
  );
}

function Logo({ size = 40 }) {
  return (
    <div style={{
      width: size, height: size, borderRadius: size * 0.3, background: 'var(--accent)',
      display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0,
      boxShadow: '0 8px 18px -6px var(--accent)',
    }}>
      <UI.Icon name="code" size={size * 0.56} stroke="#fff" sw={2.4} />
    </div>
  );
}

// ── Sign up / Sign in ────────────────────────────────────────
function Auth({ mode, profile, patch, onDone, onBack }) {
  const signup = mode === 'signup';
  const ok = profile.email.includes('@') && profile.name.length > 1;
  const field = (label, key, type, ph) => (
    <div style={{ display: 'flex', flexDirection: 'column', gap: 7 }}>
      <UI.Label>{label}</UI.Label>
      <input type={type} value={profile[key] || ''} onChange={e => patch({ [key]: e.target.value })}
        placeholder={ph} style={{
          width: '100%', boxSizing: 'border-box', padding: '15px 16px',
          border: '1.5px solid var(--line)', borderRadius: 14, fontSize: 16,
          fontFamily: 'var(--sans)', color: 'var(--ink)', outline: 'none',
        }}
        onFocus={e => e.target.style.borderColor = 'var(--accent)'}
        onBlur={e => e.target.style.borderColor = 'var(--line)'} />
    </div>
  );
  return (
    <div style={{ height: '100%', display: 'flex', flexDirection: 'column', background: 'var(--bg)' }}>
      <TopBar onBack={onBack} />
      <div style={{ flex: 1, padding: '6px 26px 0', overflowY: 'auto' }}>
        <h1 style={{ fontSize: 30, fontWeight: 800, letterSpacing: '-0.03em', color: 'var(--ink)', margin: '8px 0 6px' }}>
          {signup ? 'Create your account' : 'Welcome back'}</h1>
        <p style={{ color: 'var(--ink-2)', fontSize: 15.5, margin: '0 0 26px' }}>
          {signup ? 'Two quick fields, then four questions.' : 'Sign in to keep matching.'}</p>
        <div style={{ display: 'flex', flexDirection: 'column', gap: 16 }}>
          {signup && field('Name', 'name', 'text', 'Your name')}
          {field('Email', 'email', 'email', 'you@example.com')}
          {field('Password', 'password', 'password', '••••••••')}
        </div>
        <div style={{ display: 'flex', alignItems: 'center', gap: 12, margin: '24px 0' }}>
          <div style={{ flex: 1, height: 1, background: 'var(--line)' }} />
          <span style={{ fontFamily: 'var(--mono)', fontSize: 12, color: 'var(--ink-3)' }}>OR</span>
          <div style={{ flex: 1, height: 1, background: 'var(--line)' }} />
        </div>
        <div style={{ display: 'flex', flexDirection: 'column', gap: 10 }}>
          <UI.Btn full variant="outline" onClick={() => { patch({ name: profile.name || 'You', email: profile.email || 'you@devmatch.io' }); onDone(); }}>
            Continue with GitHub</UI.Btn>
        </div>
      </div>
      <div style={{ padding: '14px 24px 40px' }}>
        <UI.Btn full disabled={signup && !ok} onClick={onDone} icon="arrowRight">
          {signup ? 'Continue' : 'Sign in'}</UI.Btn>
      </div>
    </div>
  );
}

function TopBar({ onBack, right, title }) {
  return (
    <div style={{
      display: 'flex', alignItems: 'center', gap: 12, padding: '60px 18px 10px', flexShrink: 0,
    }}>
      <button onClick={onBack} style={{
        width: 40, height: 40, borderRadius: 999, border: '1.5px solid var(--line)',
        background: '#fff', display: 'flex', alignItems: 'center', justifyContent: 'center',
        cursor: 'pointer', flexShrink: 0, WebkitTapHighlightColor: 'transparent',
      }}><UI.Icon name="arrowLeft" size={20} stroke="var(--ink)" /></button>
      {title && <div style={{ fontWeight: 700, fontSize: 17, color: 'var(--ink)' }}>{title}</div>}
      <div style={{ flex: 1 }} />
      {right}
    </div>
  );
}

// ── Onboarding container (switches by flow tweak) ────────────
function Onboarding({ flow, profile, patch, onDone, onBack }) {
  if (flow === 'one-page') return <OnboardOnePage profile={profile} patch={patch} onDone={onDone} onBack={onBack} />;
  if (flow === 'chat') return <OnboardChat profile={profile} patch={patch} onDone={onDone} onBack={onBack} />;
  return <OnboardStepped profile={profile} patch={patch} onDone={onDone} onBack={onBack} />;
}

// Variant A — Stepped (one question per screen)
function OnboardStepped({ profile, patch, onDone, onBack }) {
  const [i, setI] = oUseState(0);
  const cur = Q[i];
  const back = () => i === 0 ? onBack() : setI(i - 1);
  const next = () => i === Q.length - 1 ? onDone() : setI(i + 1);
  return (
    <div style={{ height: '100%', display: 'flex', flexDirection: 'column', background: 'var(--bg)' }}>
      <div style={{ padding: '60px 22px 0', display: 'flex', alignItems: 'center', gap: 14 }}>
        <button onClick={back} style={navBtn}><UI.Icon name="arrowLeft" size={20} stroke="var(--ink)" /></button>
        <div style={{ flex: 1 }}><UI.Progress step={i} total={Q.length} /></div>
        <span style={{ fontFamily: 'var(--mono)', fontSize: 13, color: 'var(--ink-3)', fontWeight: 600 }}>{i + 1}/{Q.length}</span>
      </div>
      <div key={i} style={{ flex: 1, padding: '26px 26px 0', overflowY: 'auto', animation: 'dmSlideIn .32s cubic-bezier(.2,.8,.2,1)' }}>
        <h1 style={{ fontSize: 27, fontWeight: 800, letterSpacing: '-0.03em', color: 'var(--ink)', margin: '0 0 8px', textWrap: 'balance' }}>{cur.q}</h1>
        <p style={{ color: 'var(--ink-2)', fontSize: 15, margin: '0 0 24px', lineHeight: 1.45 }}>{cur.sub}</p>
        {cur.render(profile, patch)}
      </div>
      <div style={{ padding: '14px 24px 40px' }}>
        <UI.Btn full disabled={!cur.valid(profile)} onClick={next} icon={i === Q.length - 1 ? 'check' : 'arrowRight'}>
          {i === Q.length - 1 ? 'Finish & start matching' : 'Continue'}</UI.Btn>
      </div>
    </div>
  );
}

// Variant B — One scrollable page
function OnboardOnePage({ profile, patch, onDone, onBack }) {
  const done = Q.every(q => q.valid(profile));
  return (
    <div style={{ height: '100%', display: 'flex', flexDirection: 'column', background: 'var(--bg)' }}>
      <TopBar onBack={onBack} title="Build your profile" />
      <div style={{ flex: 1, overflowY: 'auto', padding: '6px 24px 24px' }}>
        {Q.map((q, idx) => (
          <div key={q.key} style={{ marginBottom: 30 }}>
            <div style={{ display: 'flex', alignItems: 'baseline', gap: 10, marginBottom: 4 }}>
              <span style={{ fontFamily: 'var(--mono)', fontSize: 13, fontWeight: 700, color: 'var(--accent)' }}>{idx + 1}</span>
              <h2 style={{ fontSize: 20, fontWeight: 800, letterSpacing: '-0.02em', color: 'var(--ink)', margin: 0 }}>{q.q}</h2>
            </div>
            <p style={{ color: 'var(--ink-2)', fontSize: 14, margin: '0 0 16px 23px' }}>{q.sub}</p>
            <div style={{ marginLeft: 0 }}>{q.render(profile, patch)}</div>
          </div>
        ))}
      </div>
      <div style={{ padding: '14px 24px 40px', borderTop: '1px solid var(--line)', background: 'var(--bg)' }}>
        <UI.Btn full disabled={!done} onClick={onDone} icon="check">Create profile</UI.Btn>
      </div>
    </div>
  );
}

// Variant C — Chat / conversational
function OnboardChat({ profile, patch, onDone, onBack }) {
  const [step, setStep] = oUseState(0); // how many answered
  const scroller = oUseRef(null);
  oUseEffect(() => { if (scroller.current) scroller.current.scrollTop = scroller.current.scrollHeight; }, [step]);
  const cur = Q[step];
  const answerText = (q) => {
    if (q.key === 'role') return profile.role + (profile.headline ? ` — ${profile.headline}` : '');
    if (q.key === 'skills') return profile.skills.join(' · ');
    if (q.key === 'goals') return profile.goals.map(id => DM.GOALS.find(g => g.id === id)?.label).join(', ');
    if (q.key === 'avail') return DM.AVAIL.find(a => a.id === profile.avail)?.label;
  };
  return (
    <div style={{ height: '100%', display: 'flex', flexDirection: 'column', background: 'var(--bg)' }}>
      <div style={{ padding: '60px 22px 12px', display: 'flex', alignItems: 'center', gap: 12, borderBottom: '1px solid var(--line)' }}>
        <button onClick={onBack} style={navBtn}><UI.Icon name="arrowLeft" size={20} stroke="var(--ink)" /></button>
        <Logo size={34} />
        <div>
          <div style={{ fontWeight: 700, fontSize: 15.5, color: 'var(--ink)' }}>DevMatch</div>
          <div style={{ fontFamily: 'var(--mono)', fontSize: 11.5, color: 'var(--accent-ink)' }}>● setting you up</div>
        </div>
      </div>
      <div ref={scroller} style={{ flex: 1, overflowY: 'auto', padding: '20px 20px 8px', display: 'flex', flexDirection: 'column', gap: 12 }}>
        {Q.slice(0, step + 1).map((q, idx) => (
          <React.Fragment key={q.key}>
            <Bubble side="them"><b>{q.q}</b><br /><span style={{ opacity: .8, fontSize: 13.5 }}>{q.sub}</span></Bubble>
            {idx < step && <Bubble side="me">{answerText(q)}</Bubble>}
          </React.Fragment>
        ))}
        {step >= Q.length && <Bubble side="them">Perfect — your profile is live. Let's find your team! 🎉</Bubble>}
      </div>
      <div style={{ padding: '12px 18px 30px', borderTop: '1px solid var(--line)', background: 'var(--surface)' }}>
        {step < Q.length ? (
          <div style={{ display: 'flex', flexDirection: 'column', gap: 12 }}>
            <div style={{ maxHeight: 230, overflowY: 'auto' }}>{cur.render(profile, patch)}</div>
            <UI.Btn full size="md" disabled={!cur.valid(profile)} onClick={() => setStep(step + 1)} icon="send">Send answer</UI.Btn>
          </div>
        ) : (
          <UI.Btn full onClick={onDone} icon="rocket">Start matching</UI.Btn>
        )}
      </div>
    </div>
  );
}

function Bubble({ side, children }) {
  const me = side === 'me';
  return (
    <div style={{ display: 'flex', justifyContent: me ? 'flex-end' : 'flex-start', animation: 'dmSlideIn .3s ease' }}>
      <div style={{
        maxWidth: '82%', padding: '11px 15px', fontSize: 14.5, lineHeight: 1.4,
        borderRadius: me ? '18px 18px 5px 18px' : '18px 18px 18px 5px',
        background: me ? 'var(--accent)' : '#fff', color: me ? '#fff' : 'var(--ink)',
        border: me ? 'none' : '1px solid var(--line)', fontWeight: me ? 600 : 500,
        boxShadow: me ? '0 6px 16px -8px var(--accent)' : '0 2px 8px rgba(15,26,22,.04)',
      }}>{children}</div>
    </div>
  );
}

const navBtn = {
  width: 40, height: 40, borderRadius: 999, border: '1.5px solid var(--line)',
  background: '#fff', display: 'flex', alignItems: 'center', justifyContent: 'center',
  cursor: 'pointer', flexShrink: 0, WebkitTapHighlightColor: 'transparent', padding: 0,
};

Object.assign(window, { Welcome, Auth, Onboarding, TopBar, Logo, navBtn, Bubble });
