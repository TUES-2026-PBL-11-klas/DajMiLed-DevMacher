// screens.jsx — Detail, Match modal, Matches inbox, Chat, Profile, Post task
const { useState: sUseState, useRef: sUseRef, useEffect: sUseEffect } = React;

// ── Detail (task or person) ──────────────────────────────────
function Detail({ item, onBack, onApply, applied }) {
  const isTask = item.kind === 'task';
  return (
    <div style={{ height: '100%', display: 'flex', flexDirection: 'column', background: 'var(--bg)' }}>
      <div style={{ position: 'relative', height: 230, flexShrink: 0 }}>
        <PlaceholderArt data={item.avatar} label={isTask ? 'project cover' : 'photo'} />
        <button onClick={onBack} style={{
          position: 'absolute', top: 56, left: 16, width: 42, height: 42, borderRadius: 999,
          border: 'none', background: '#fff', display: 'flex', alignItems: 'center', justifyContent: 'center',
          cursor: 'pointer', boxShadow: '0 4px 12px rgba(0,0,0,.12)', WebkitTapHighlightColor: 'transparent',
        }}><UI.Icon name="arrowLeft" size={22} stroke="var(--ink)" /></button>
        <div style={{ position: 'absolute', top: 56, right: 16 }}><MatchRing value={isTask ? item.match : 88} dark /></div>
      </div>
      <div style={{ flex: 1, overflowY: 'auto', marginTop: -28 }}>
        <div style={{ background: 'var(--bg)', borderRadius: '28px 28px 0 0', padding: '22px 22px 30px', minHeight: '100%' }}>
          <div style={{ display: 'flex', gap: 8, marginBottom: 12 }}>
            {isTask && <UI.Tag tone="accent" size="sm">{item.category}</UI.Tag>}
            <UI.Tag size="sm">{isTask ? item.posted : item.location}</UI.Tag>
          </div>
          <h1 style={{ fontSize: 25, fontWeight: 800, letterSpacing: '-0.03em', color: 'var(--ink)', margin: '0 0 8px', lineHeight: 1.1 }}>
            {isTask ? item.title : `${item.name}, ${item.age}`}</h1>
          <div style={{ display: 'flex', alignItems: 'center', gap: 10, marginBottom: 20 }}>
            <UI.Avatar data={isTask ? item.ownerAvatar : item.avatar} size={34} />
            <span style={{ fontSize: 14.5, color: 'var(--ink-2)', fontWeight: 600 }}>
              {isTask ? `${item.owner} · ${item.project}` : item.role}</span>
          </div>

          <div style={{ display: 'flex', gap: 10, marginBottom: 22 }}>
            <StatCard icon="clock" top={isTask ? item.commitment : item.availability} bot={isTask ? 'commitment' : 'available'} />
            <StatCard icon={isTask ? 'briefcase' : 'star'} top={isTask ? item.length.split(' · ')[0] : item.stats.rating} bot={isTask ? 'duration' : 'rating'} />
            <StatCard icon={isTask ? 'user' : 'layers'} top={isTask ? `${item.applicants}` : item.stats.projects} bot={isTask ? 'applied' : 'projects'} />
          </div>

          <Section title={isTask ? 'About the task' : 'About'}>
            <p style={{ fontSize: 15, lineHeight: 1.55, color: 'var(--ink-2)', margin: 0 }}>{isTask ? item.summary : item.bio}</p>
          </Section>

          <Section title="Skills">
            <div style={{ display: 'flex', flexWrap: 'wrap', gap: 8 }}>
              {item.skills.map(s => <UI.Tag key={s} tone="accent">{s}</UI.Tag>)}
            </div>
          </Section>

          {isTask ? (
            <Section title="What you'll do">
              <div style={{ display: 'flex', flexDirection: 'column', gap: 11 }}>
                {item.details.map((d, i) => (
                  <div key={i} style={{ display: 'flex', gap: 11, alignItems: 'flex-start' }}>
                    <span style={{ width: 22, height: 22, borderRadius: 999, background: 'var(--accent-soft)', flexShrink: 0, marginTop: 1,
                      display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
                      <UI.Icon name="check" size={13} stroke="var(--accent-ink)" sw={2.6} /></span>
                    <span style={{ fontSize: 14.5, color: 'var(--ink)', lineHeight: 1.45 }}>{d}</span>
                  </div>
                ))}
              </div>
            </Section>
          ) : (
            <Section title="Highlights">
              <div style={{ display: 'flex', flexDirection: 'column', gap: 9 }}>
                {item.highlights.map((h, i) => (
                  <div key={i} style={{ display: 'flex', gap: 10, alignItems: 'center', padding: '12px 14px', background: '#fff', borderRadius: 14, border: '1px solid var(--line)' }}>
                    <span style={{ fontSize: 15 }}>{h.split(' ')[0]}</span>
                    <span style={{ fontSize: 14, color: 'var(--ink)', fontWeight: 500 }}>{h.split(' ').slice(1).join(' ')}</span>
                  </div>
                ))}
              </div>
            </Section>
          )}
          <div style={{ height: 90 }} />
        </div>
      </div>
      <div style={{ position: 'absolute', left: 0, right: 0, bottom: 0, padding: '14px 22px 30px',
        background: 'linear-gradient(transparent, var(--bg) 24%)' }}>
        <UI.Btn full disabled={applied} icon={applied ? 'check' : 'send'}
          onClick={() => onApply(item)}>
          {applied ? 'Application sent' : (isTask ? 'Apply to this task' : `Connect with ${item.name.split(' ')[0]}`)}</UI.Btn>
      </div>
    </div>
  );
}

function StatCard({ icon, top, bot }) {
  return (
    <div style={{ flex: 1, background: '#fff', border: '1px solid var(--line)', borderRadius: 16, padding: '13px 12px', display: 'flex', flexDirection: 'column', gap: 6 }}>
      <UI.Icon name={icon} size={18} stroke="var(--accent)" />
      <div style={{ fontWeight: 700, fontSize: 14.5, color: 'var(--ink)', whiteSpace: 'nowrap', overflow: 'hidden', textOverflow: 'ellipsis' }}>{top}</div>
      <div style={{ fontFamily: 'var(--mono)', fontSize: 10.5, color: 'var(--ink-3)', textTransform: 'uppercase', letterSpacing: '0.06em' }}>{bot}</div>
    </div>
  );
}

function Section({ title, children }) {
  return (
    <div style={{ marginBottom: 24 }}>
      <UI.Label style={{ marginBottom: 11 }}>{title}</UI.Label>
      {children}
    </div>
  );
}

// ── Match modal ──────────────────────────────────────────────
function MatchModal({ data, onMessage, onClose }) {
  if (!data) return null;
  const { item } = data;
  const name = item.kind === 'task' ? item.owner : item.name;
  return (
    <div style={{
      position: 'absolute', inset: 0, zIndex: 95, display: 'flex', flexDirection: 'column',
      alignItems: 'center', justifyContent: 'center', padding: '0 32px', textAlign: 'center',
      background: 'linear-gradient(160deg, var(--accent-ink), var(--accent))', overflow: 'hidden',
    }}>
      {[...Array(14)].map((_, i) => (
        <span key={i} style={{
          position: 'absolute', width: 10, height: 10, borderRadius: 3,
          background: ['#fff', '#FFE08A', '#BFF3DC'][i % 3],
          left: `${(i * 67) % 100}%`, top: `${(i * 37) % 100}%`,
          opacity: 0.8, animation: `dmFloat ${2 + (i % 4)}s ease-in-out ${i * 0.12}s infinite`,
        }} />
      ))}
      <div style={{ position: 'relative', zIndex: 1, animation: 'dmPop .5s cubic-bezier(.2,1.3,.4,1)' }}>
        <div style={{ fontFamily: 'var(--mono)', color: '#fff', opacity: .85, fontSize: 14, letterSpacing: '0.1em', marginBottom: 6 }}>● ● ●</div>
        <h1 style={{ fontSize: 44, fontWeight: 800, color: '#fff', letterSpacing: '-0.03em', margin: '0 0 8px' }}>It's a match!</h1>
        <p style={{ color: '#ffffffdd', fontSize: 16, margin: '0 0 30px', lineHeight: 1.45 }}>
          You and {name.split(' ')[0]} are interested in working together.</p>
        <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'center', gap: -10, marginBottom: 34 }}>
          <div style={{ transform: 'rotate(-7deg)' }}><UI.Avatar data={DM.AVATARS.you} size={92} ring /></div>
          <div style={{
            width: 44, height: 44, borderRadius: 999, background: '#fff', margin: '0 -8px', zIndex: 2,
            display: 'flex', alignItems: 'center', justifyContent: 'center', boxShadow: '0 6px 16px rgba(0,0,0,.2)',
          }}><UI.Icon name="heart" size={22} stroke="var(--accent)" fill="var(--accent)" /></div>
          <div style={{ transform: 'rotate(7deg)' }}><UI.Avatar data={item.kind === 'task' ? item.ownerAvatar : item.avatar} size={92} ring /></div>
        </div>
      </div>
      <div style={{ position: 'relative', zIndex: 1, width: '100%', display: 'flex', flexDirection: 'column', gap: 11 }}>
        <UI.Btn full variant="dark" icon="chat" onClick={onMessage} style={{ background: '#fff', color: 'var(--accent-ink)' }}>Send a message</UI.Btn>
        <button onClick={onClose} style={{ background: 'none', border: 'none', color: '#fff', fontWeight: 600, fontSize: 15, cursor: 'pointer', padding: 10, fontFamily: 'var(--sans)' }}>Keep swiping</button>
      </div>
    </div>
  );
}

// ── Matches inbox ────────────────────────────────────────────
function Matches({ matches, applications, onOpenChat }) {
  const [tab, setTab] = sUseState('chats');
  return (
    <div style={{ height: '100%', display: 'flex', flexDirection: 'column', background: 'var(--bg)' }}>
      <div style={{ padding: '58px 20px 6px', flexShrink: 0 }}>
        <h1 style={{ fontSize: 28, fontWeight: 800, letterSpacing: '-0.03em', color: 'var(--ink)', margin: '0 0 14px' }}>Matches</h1>
        <div style={{ display: 'flex', gap: 8 }}>
          {[['chats', `Chats`], ['applied', `Applied · ${applications.length}`]].map(([k, l]) => (
            <button key={k} onClick={() => setTab(k)} style={{
              padding: '9px 16px', borderRadius: 999, border: 'none', cursor: 'pointer',
              fontWeight: 600, fontSize: 14, fontFamily: 'var(--sans)',
              background: tab === k ? 'var(--ink)' : 'var(--surface-2)', color: tab === k ? '#fff' : 'var(--ink-2)',
            }}>{l}</button>
          ))}
        </div>
      </div>
      <div style={{ flex: 1, overflowY: 'auto', padding: '12px 16px 24px' }}>
        {tab === 'chats' ? (
          <div style={{ display: 'flex', flexDirection: 'column', gap: 6 }}>
            {matches.map(m => (
              <button key={m.id} onClick={() => onOpenChat(m)} style={{
                display: 'flex', alignItems: 'center', gap: 13, padding: '12px', borderRadius: 18,
                border: 'none', background: '#fff', cursor: 'pointer', textAlign: 'left', width: '100%',
                boxShadow: '0 2px 8px rgba(15,26,22,.04)', WebkitTapHighlightColor: 'transparent',
              }}>
                <div style={{ position: 'relative' }}>
                  <UI.Avatar data={m.avatar} size={52} />
                  {m.unread > 0 && <span style={{ position: 'absolute', top: -2, right: -2, minWidth: 19, height: 19, borderRadius: 999,
                    background: 'var(--accent)', color: '#fff', fontSize: 11, fontWeight: 700, display: 'flex', alignItems: 'center',
                    justifyContent: 'center', border: '2px solid #fff', fontFamily: 'var(--mono)' }}>{m.unread}</span>}
                </div>
                <div style={{ flex: 1, minWidth: 0 }}>
                  <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'baseline', gap: 8 }}>
                    <span style={{ fontWeight: 700, fontSize: 15.5, color: 'var(--ink)' }}>{m.name}</span>
                    <span style={{ fontFamily: 'var(--mono)', fontSize: 11.5, color: 'var(--ink-3)', flexShrink: 0 }}>{m.time}</span>
                  </div>
                  <div style={{ fontFamily: 'var(--mono)', fontSize: 11, color: 'var(--accent-ink)', margin: '2px 0 3px' }}>{m.context}</div>
                  <div style={{ fontSize: 13.5, color: m.unread ? 'var(--ink)' : 'var(--ink-2)', fontWeight: m.unread ? 600 : 400,
                    whiteSpace: 'nowrap', overflow: 'hidden', textOverflow: 'ellipsis' }}>{m.preview}</div>
                </div>
              </button>
            ))}
          </div>
        ) : (
          <div style={{ display: 'flex', flexDirection: 'column', gap: 8 }}>
            {applications.length === 0 && <EmptyState text="No applications yet. Swipe right on a task to apply." />}
            {applications.map((a, i) => (
              <div key={i} style={{ display: 'flex', alignItems: 'center', gap: 13, padding: '13px 14px', borderRadius: 16, background: '#fff', border: '1px solid var(--line)' }}>
                <UI.Avatar data={a.avatar} size={44} />
                <div style={{ flex: 1, minWidth: 0 }}>
                  <div style={{ fontWeight: 700, fontSize: 14.5, color: 'var(--ink)', whiteSpace: 'nowrap', overflow: 'hidden', textOverflow: 'ellipsis' }}>
                    {a.kind === 'task' ? a.title : a.name}</div>
                  <div style={{ fontSize: 12.5, color: 'var(--ink-2)' }}>{a.kind === 'task' ? a.project : a.role}</div>
                </div>
                <UI.Tag tone="accent" size="sm">Sent</UI.Tag>
              </div>
            ))}
          </div>
        )}
      </div>
    </div>
  );
}

function EmptyState({ text }) {
  return <div style={{ textAlign: 'center', padding: '50px 24px', color: 'var(--ink-3)', fontSize: 14.5, lineHeight: 1.5 }}>{text}</div>;
}

// ── Chat thread ──────────────────────────────────────────────
function Chat({ match, onBack }) {
  const [msgs, setMsgs] = sUseState(match.thread);
  const [text, setText] = sUseState('');
  const scroller = sUseRef(null);
  sUseEffect(() => { if (scroller.current) scroller.current.scrollTop = scroller.current.scrollHeight; }, [msgs]);
  const send = () => {
    if (!text.trim()) return;
    setMsgs([...msgs, { from: 'me', text: text.trim(), time: 'now' }]);
    setText('');
    setTimeout(() => setMsgs(m => [...m, { from: 'them', text: 'Sounds great — let\u2019s do it! 🚀', time: 'now' }]), 1100);
  };
  return (
    <div style={{ height: '100%', display: 'flex', flexDirection: 'column', background: 'var(--bg)' }}>
      <div style={{ padding: '56px 16px 12px', display: 'flex', alignItems: 'center', gap: 12, borderBottom: '1px solid var(--line)', background: 'var(--surface)' }}>
        <button onClick={onBack} style={navBtn}><UI.Icon name="arrowLeft" size={20} stroke="var(--ink)" /></button>
        <UI.Avatar data={match.avatar} size={40} />
        <div style={{ flex: 1 }}>
          <div style={{ fontWeight: 700, fontSize: 15.5, color: 'var(--ink)' }}>{match.name}</div>
          <div style={{ fontFamily: 'var(--mono)', fontSize: 11, color: 'var(--accent-ink)' }}>{match.context}</div>
        </div>
      </div>
      <div ref={scroller} style={{ flex: 1, overflowY: 'auto', padding: '18px 16px', display: 'flex', flexDirection: 'column', gap: 9 }}>
        <div style={{ textAlign: 'center', margin: '0 0 8px' }}>
          <span style={{ fontFamily: 'var(--mono)', fontSize: 11.5, color: 'var(--ink-3)', background: 'var(--surface-2)', padding: '5px 12px', borderRadius: 999 }}>You matched on {match.context}</span>
        </div>
        {msgs.map((m, i) => <Bubble key={i} side={m.from === 'me' ? 'me' : 'them'}>{m.text}</Bubble>)}
      </div>
      <div style={{ padding: '10px 14px 28px', borderTop: '1px solid var(--line)', background: 'var(--surface)', display: 'flex', gap: 10, alignItems: 'center' }}>
        <input value={text} onChange={e => setText(e.target.value)} onKeyDown={e => e.key === 'Enter' && send()}
          placeholder="Message…" style={{
            flex: 1, padding: '13px 16px', borderRadius: 999, border: '1.5px solid var(--line)',
            fontSize: 15, fontFamily: 'var(--sans)', outline: 'none', background: 'var(--bg)',
          }}
          onFocus={e => e.target.style.borderColor = 'var(--accent)'}
          onBlur={e => e.target.style.borderColor = 'var(--line)'} />
        <button onClick={send} style={{
          width: 46, height: 46, borderRadius: 999, border: 'none', background: 'var(--accent)', cursor: 'pointer',
          display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0,
          boxShadow: '0 8px 18px -8px var(--accent)',
        }}><UI.Icon name="send" size={20} stroke="#fff" /></button>
      </div>
    </div>
  );
}

// ── Profile ──────────────────────────────────────────────────
function Profile({ profile }) {
  const goals = profile.goals.map(id => DM.GOALS.find(g => g.id === id)).filter(Boolean);
  const avail = DM.AVAIL.find(a => a.id === profile.avail);
  return (
    <div style={{ height: '100%', display: 'flex', flexDirection: 'column', background: 'var(--bg)' }}>
      <div style={{ flex: 1, overflowY: 'auto' }}>
        <div style={{ background: 'linear-gradient(160deg, var(--accent-soft), var(--bg) 70%)', padding: '60px 22px 18px' }}>
          <div style={{ display: 'flex', justifyContent: 'flex-end', marginBottom: 6 }}>
            <button style={iconBtn}><UI.Icon name="edit" size={18} stroke="var(--ink-2)" /></button>
          </div>
          <div style={{ display: 'flex', alignItems: 'center', gap: 16 }}>
            <UI.Avatar data={DM.AVATARS.you} size={78} />
            <div style={{ minWidth: 0 }}>
              <h1 style={{ fontSize: 24, fontWeight: 800, letterSpacing: '-0.03em', color: 'var(--ink)', margin: 0 }}>{profile.name || 'You'}</h1>
              <div style={{ fontSize: 14.5, color: 'var(--ink-2)', fontWeight: 600, marginTop: 2 }}>{profile.role || 'Developer'}</div>
              {profile.headline && <div style={{ fontSize: 13.5, color: 'var(--ink-3)', marginTop: 2 }}>{profile.headline}</div>}
            </div>
          </div>
        </div>
        <div style={{ padding: '6px 22px 30px' }}>
          <div style={{ display: 'flex', gap: 10, marginBottom: 24 }}>
            <StatCard icon="send" top={'—'} bot="applied" />
            <StatCard icon="heart" top={'3'} bot="matches" />
            <StatCard icon="clock" top={avail ? avail.label.split(' ')[0] + 'h' : '—'} bot="per week" />
          </div>
          <Section title="Skills">
            <div style={{ display: 'flex', flexWrap: 'wrap', gap: 8 }}>
              {profile.skills.length ? profile.skills.map(s => <UI.Tag key={s} tone="accent">{s}</UI.Tag>)
                : <span style={{ color: 'var(--ink-3)', fontSize: 14 }}>No skills yet</span>}
            </div>
          </Section>
          <Section title="Looking for">
            <div style={{ display: 'flex', flexDirection: 'column', gap: 9 }}>
              {goals.length ? goals.map(g => (
                <div key={g.id} style={{ display: 'flex', alignItems: 'center', gap: 12, padding: '13px 15px', background: '#fff', borderRadius: 14, border: '1px solid var(--line)' }}>
                  <span style={{ fontSize: 18 }}>{g.emoji}</span>
                  <span style={{ fontSize: 14.5, color: 'var(--ink)', fontWeight: 500 }}>{g.label}</span>
                </div>
              )) : <span style={{ color: 'var(--ink-3)', fontSize: 14 }}>Not set</span>}
            </div>
          </Section>
          <Section title="Availability">
            <div style={{ padding: '15px 16px', background: 'var(--accent-soft)', borderRadius: 16, display: 'flex', alignItems: 'center', gap: 12 }}>
              <UI.Icon name="clock" size={22} stroke="var(--accent-ink)" />
              <div>
                <div style={{ fontWeight: 700, fontSize: 15.5, color: 'var(--accent-ink)' }}>{avail ? avail.label : 'Not set'}</div>
                <div style={{ fontFamily: 'var(--mono)', fontSize: 12, color: 'var(--accent-ink)', opacity: .7 }}>{avail ? avail.sub : ''}</div>
              </div>
            </div>
          </Section>
          <UI.Btn full variant="outline" icon="edit">Edit profile</UI.Btn>
        </div>
      </div>
    </div>
  );
}

// ── Post a task ──────────────────────────────────────────────
function PostTask({ onBack, onPublish }) {
  const [f, setF] = sUseState({ title: '', project: '', category: 'Backend', skills: [], commitment: 'some', summary: '' });
  const patch = (p) => setF({ ...f, ...p });
  const cats = ['Backend', 'Frontend', 'Mobile', 'DevOps', 'ML', 'Design'];
  const ok = f.title.length > 4 && f.project.length > 1 && f.skills.length >= 1;
  const toggle = (s) => patch({ skills: f.skills.includes(s) ? f.skills.filter(x => x !== s) : [...f.skills, s] });
  return (
    <div style={{ height: '100%', display: 'flex', flexDirection: 'column', background: 'var(--bg)' }}>
      <TopBar onBack={onBack} title="Post a task" />
      <div style={{ flex: 1, overflowY: 'auto', padding: '6px 22px 24px', display: 'flex', flexDirection: 'column', gap: 20 }}>
        <Field label="Task title">
          <input value={f.title} onChange={e => patch({ title: e.target.value })} placeholder="e.g. Backend dev for a tournament app" style={inp} onFocus={fc} onBlur={bl} />
        </Field>
        <Field label="Project name">
          <input value={f.project} onChange={e => patch({ project: e.target.value })} placeholder="e.g. BracketUp" style={inp} onFocus={fc} onBlur={bl} />
        </Field>
        <Field label="Category">
          <div style={{ display: 'flex', flexWrap: 'wrap', gap: 8 }}>
            {cats.map(c => (
              <button key={c} onClick={() => patch({ category: c })} style={{
                padding: '9px 14px', borderRadius: 12, cursor: 'pointer', fontFamily: 'var(--sans)', fontWeight: 600, fontSize: 14,
                border: `1.5px solid ${f.category === c ? 'var(--accent)' : 'var(--line)'}`,
                background: f.category === c ? 'var(--accent-soft)' : '#fff', color: f.category === c ? 'var(--accent-ink)' : 'var(--ink)',
              }}>{c}</button>
            ))}
          </div>
        </Field>
        <Field label="Skills needed">
          <div style={{ display: 'flex', flexWrap: 'wrap', gap: 7 }}>
            {DM.ALL_SKILLS.slice(0, 16).map(s => {
              const on = f.skills.includes(s);
              return <button key={s} onClick={() => toggle(s)} style={{
                padding: '7px 12px', borderRadius: 999, cursor: 'pointer', fontFamily: 'var(--mono)', fontSize: 13, fontWeight: 500,
                border: `1.5px solid ${on ? 'var(--accent)' : 'var(--line)'}`, background: on ? 'var(--accent)' : '#fff', color: on ? '#fff' : 'var(--ink-2)',
              }}>{on ? '' : '+ '}{s}</button>;
            })}
          </div>
        </Field>
        <Field label="Description">
          <textarea value={f.summary} onChange={e => patch({ summary: e.target.value })} rows={4} placeholder="What's the project, and who are you looking for?" style={{ ...inp, resize: 'none' }} onFocus={fc} onBlur={bl} />
        </Field>
      </div>
      <div style={{ padding: '14px 22px 34px', borderTop: '1px solid var(--line)' }}>
        <UI.Btn full disabled={!ok} icon="rocket" onClick={() => onPublish(f)}>Publish task</UI.Btn>
      </div>
    </div>
  );
}

function Field({ label, children }) {
  return <div style={{ display: 'flex', flexDirection: 'column', gap: 9 }}><UI.Label>{label}</UI.Label>{children}</div>;
}
const inp = { width: '100%', boxSizing: 'border-box', padding: '14px 16px', border: '1.5px solid var(--line)', borderRadius: 14, fontSize: 15.5, fontFamily: 'var(--sans)', color: 'var(--ink)', outline: 'none' };
const fc = e => e.target.style.borderColor = 'var(--accent)';
const bl = e => e.target.style.borderColor = 'var(--line)';

Object.assign(window, { Detail, MatchModal, Matches, Chat, Profile, PostTask });
