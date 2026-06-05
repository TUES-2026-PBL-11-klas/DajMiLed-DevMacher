// discover.jsx — Swipe deck, card-style variants, apply flows, match modal
const { useState: dUseState, useRef: dUseRef, useEffect: dUseEffect } = React;

const THRESH = 95;

// ── Card content renderers (3 styles × 2 modes) ──────────────
function MatchRing({ value, dark }) {
  return (
    <div style={{
      display: 'inline-flex', alignItems: 'center', gap: 6, padding: '5px 11px 5px 8px',
      borderRadius: 999, background: dark ? 'rgba(255,255,255,.18)' : 'var(--accent-soft)',
      color: dark ? '#fff' : 'var(--accent-ink)', fontFamily: 'var(--mono)', fontWeight: 600, fontSize: 13,
    }}>
      <span style={{ width: 7, height: 7, borderRadius: 999, background: dark ? '#fff' : 'var(--accent)' }} />
      {value}% match
    </div>
  );
}

function CardShell({ children, style }) {
  return <div style={{
    width: '100%', height: '100%', background: '#fff', borderRadius: 26, overflow: 'hidden',
    boxShadow: '0 18px 44px -18px rgba(15,26,22,.28), 0 2px 6px rgba(15,26,22,.05)',
    display: 'flex', flexDirection: 'column', ...style,
  }}>{children}</div>;
}

function PlaceholderArt({ data, label }) {
  return (
    <div style={{
      position: 'relative', width: '100%', height: '100%', overflow: 'hidden',
      background: data.bg,
      backgroundImage: `repeating-linear-gradient(135deg, ${data.fg}14 0 12px, transparent 12px 24px)`,
      display: 'flex', alignItems: 'center', justifyContent: 'center',
    }}>
      <div style={{
        width: 96, height: 96, borderRadius: 28, background: '#fff', display: 'flex',
        alignItems: 'center', justifyContent: 'center', color: data.fg, fontWeight: 800,
        fontSize: 34, fontFamily: 'var(--mono)', boxShadow: '0 10px 24px -10px rgba(0,0,0,.2)',
      }}>{data.initials}</div>
      {label && <span style={{
        position: 'absolute', bottom: 12, left: 12, fontFamily: 'var(--mono)', fontSize: 11,
        color: data.fg, background: '#ffffffcc', padding: '4px 8px', borderRadius: 7,
      }}>{label}</span>}
    </div>
  );
}

function renderCard(item, style, expand) {
  const isTask = item.kind === 'task';
  if (style === 'minimal') return <CardMinimal item={item} isTask={isTask} expand={expand} />;
  if (style === 'accent') return <CardAccent item={item} isTask={isTask} expand={expand} />;
  return <CardDetailed item={item} isTask={isTask} expand={expand} />;
}

// Style 1 — Detailed
function CardDetailed({ item, isTask, expand }) {
  return (
    <CardShell>
      <div style={{ padding: '20px 20px 0', display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
        {isTask
          ? <UI.Tag tone="accent" size="sm">{item.category}</UI.Tag>
          : <span style={{ fontFamily: 'var(--mono)', fontSize: 12, color: 'var(--ink-3)' }}>{item.location}</span>}
        <MatchRing value={isTask ? item.match : 88} />
      </div>
      <div style={{ padding: '14px 20px 0', display: 'flex', gap: 14, alignItems: 'center' }}>
        <UI.Avatar data={isTask ? item.avatar : item.avatar} size={56} />
        <div style={{ minWidth: 0 }}>
          <div style={{ fontSize: 20, fontWeight: 800, letterSpacing: '-0.02em', color: 'var(--ink)', lineHeight: 1.12 }}>
            {isTask ? item.title : item.name}</div>
          <div style={{ fontSize: 13.5, color: 'var(--ink-2)', marginTop: 3, fontWeight: 500 }}>
            {isTask ? `${item.project} · ${item.owner}` : item.role}</div>
        </div>
      </div>
      <div style={{ padding: '16px 20px 0', display: 'flex', flexWrap: 'wrap', gap: 7 }}>
        {item.skills.map(s => <UI.Tag key={s} size="sm">{s}</UI.Tag>)}
      </div>
      <div style={{ padding: '16px 20px 0', flex: 1, minHeight: 0 }}>
        <p style={{ fontSize: 14.5, lineHeight: 1.5, color: 'var(--ink-2)', margin: 0,
          display: '-webkit-box', WebkitLineClamp: expand ? 99 : 3, WebkitBoxOrient: 'vertical', overflow: 'hidden' }}>
          {isTask ? item.summary : item.bio}</p>
      </div>
      <div style={{ padding: '14px 20px 20px', display: 'flex', gap: 18, borderTop: '1px solid var(--surface-2)', marginTop: 14 }}>
        <Meta icon="clock" label={isTask ? item.commitment : item.availability} />
        <Meta icon={isTask ? 'briefcase' : 'star'} label={isTask ? item.length : `${item.stats.rating} · ${item.stats.projects} projects`} />
      </div>
    </CardShell>
  );
}

// Style 2 — Minimal
function CardMinimal({ item, isTask }) {
  return (
    <CardShell style={{ alignItems: 'stretch' }}>
      <div style={{ flex: 1, display: 'flex', flexDirection: 'column', justifyContent: 'center', padding: '0 26px', gap: 18 }}>
        <UI.Avatar data={item.avatar} size={84} />
        <div>
          <div style={{ fontSize: 26, fontWeight: 800, letterSpacing: '-0.03em', color: 'var(--ink)', lineHeight: 1.08, textWrap: 'balance' }}>
            {isTask ? item.title : item.name}</div>
          <div style={{ fontSize: 15, color: 'var(--ink-2)', marginTop: 6, fontWeight: 500 }}>
            {isTask ? `${item.project} · ${item.owner}` : item.role}</div>
        </div>
        <div style={{ display: 'flex', flexWrap: 'wrap', gap: 7 }}>
          {item.skills.slice(0, 4).map(s => <UI.Tag key={s} tone="outline">{s}</UI.Tag>)}
        </div>
      </div>
      <div style={{ padding: '18px 26px', borderTop: '1px solid var(--surface-2)', display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
        <span style={{ fontFamily: 'var(--mono)', fontSize: 12.5, color: 'var(--ink-3)' }}>
          {isTask ? item.commitment : item.availability}</span>
        <MatchRing value={isTask ? item.match : 88} />
      </div>
    </CardShell>
  );
}

// Style 3 — Accent header
function CardAccent({ item, isTask, expand }) {
  const data = item.avatar;
  return (
    <CardShell>
      <div style={{ height: 168, position: 'relative', flexShrink: 0 }}>
        <PlaceholderArt data={data} label={isTask ? 'project cover' : 'photo'} />
        <div style={{ position: 'absolute', top: 14, left: 14 }}>
          {isTask ? <UI.Tag tone="light" size="sm">{item.category}</UI.Tag>
                  : <UI.Tag tone="light" size="sm">{item.location}</UI.Tag>}
        </div>
        <div style={{ position: 'absolute', top: 14, right: 14 }}><MatchRing value={isTask ? item.match : 88} dark /></div>
      </div>
      <div style={{ padding: '18px 20px 0' }}>
        <div style={{ fontSize: 21, fontWeight: 800, letterSpacing: '-0.025em', color: 'var(--ink)', lineHeight: 1.1 }}>
          {isTask ? item.title : `${item.name}, ${item.age}`}</div>
        <div style={{ fontSize: 14, color: 'var(--ink-2)', marginTop: 4, fontWeight: 500 }}>
          {isTask ? `${item.project} · ${item.owner}` : item.role}</div>
      </div>
      <div style={{ padding: '14px 20px 0', display: 'flex', flexWrap: 'wrap', gap: 7 }}>
        {item.skills.map(s => <UI.Tag key={s} size="sm" tone="accent">{s}</UI.Tag>)}
      </div>
      <div style={{ padding: '14px 20px', flex: 1, minHeight: 0 }}>
        <p style={{ fontSize: 14, lineHeight: 1.5, color: 'var(--ink-2)', margin: 0,
          display: '-webkit-box', WebkitLineClamp: expand ? 99 : 2, WebkitBoxOrient: 'vertical', overflow: 'hidden' }}>
          {isTask ? item.summary : item.bio}</p>
      </div>
    </CardShell>
  );
}

function Meta({ icon, label }) {
  return (
    <div style={{ display: 'flex', alignItems: 'center', gap: 7, minWidth: 0 }}>
      <UI.Icon name={icon} size={16} stroke="var(--ink-3)" />
      <span style={{ fontSize: 12.5, color: 'var(--ink-2)', fontWeight: 500, fontFamily: 'var(--mono)', whiteSpace: 'nowrap', overflow: 'hidden', textOverflow: 'ellipsis' }}>{label}</span>
    </div>
  );
}

// ── Draggable top card ───────────────────────────────────────
function TopCard({ item, style, applyFlow, onLeft, onRight, onConfirm, onOpen, fly }) {
  const [d, setD] = dUseState({ x: 0, y: 0, t: 0 });
  const drag = dUseRef(null);
  const leaving = dUseRef(false);

  const flyOut = (dir, cb) => {
    leaving.current = true;
    const off = dir === 'right' ? 600 : -600;
    setD({ x: off, y: -40, t: 0.34 });
    setTimeout(cb, 300);
  };

  dUseEffect(() => {
    if (fly && fly.n > 0 && !leaving.current) {
      flyOut(fly.dir, () => fly.dir === 'right' ? onRight() : onLeft());
    }
  }, [fly && fly.n]);

  const down = (e) => {
    if (leaving.current) return;
    drag.current = { sx: e.clientX, sy: e.clientY, moved: false };
    e.currentTarget.setPointerCapture(e.pointerId);
  };
  const move = (e) => {
    if (!drag.current || leaving.current) return;
    const x = e.clientX - drag.current.sx, y = e.clientY - drag.current.sy;
    if (Math.abs(x) > 5) drag.current.moved = true;
    setD({ x, y: y * 0.4, t: 0 });
  };
  const up = () => {
    if (!drag.current || leaving.current) return;
    const x = d.x; const wasMoved = drag.current.moved; drag.current = null;
    if (x < -THRESH) return flyOut('left', onLeft);
    if (x > THRESH) {
      if (applyFlow === 'confirm') { setD({ x: 0, y: 0, t: 0.3 }); onConfirm(); return; }
      return flyOut('right', onRight);
    }
    setD({ x: 0, y: 0, t: 0.3 });
    if (!wasMoved) onOpen();
  };

  const rot = d.x / 22;
  const rightOp = Math.max(0, Math.min(1, d.x / 90));
  const leftOp = Math.max(0, Math.min(1, -d.x / 90));

  return (
    <div onPointerDown={down} onPointerMove={move} onPointerUp={up} onPointerCancel={up}
      style={{
        position: 'absolute', inset: 0, cursor: 'grab', touchAction: 'none',
        transform: `translate(${d.x}px, ${d.y}px) rotate(${rot}deg)`,
        transition: d.t ? `transform ${d.t}s cubic-bezier(.2,.8,.2,1)` : 'none',
        zIndex: 5,
      }}>
      {renderCard(item, style)}
      <Stamp text={item.kind === 'task' ? 'APPLY' : 'INTERESTED'} color="var(--accent)" op={rightOp} side="left" />
      <Stamp text="SKIP" color="#8A97A0" op={leftOp} side="right" />
    </div>
  );
}

function Stamp({ text, color, op, side }) {
  return (
    <div style={{
      position: 'absolute', top: 26, [side === 'left' ? 'left' : 'right']: 22,
      transform: `rotate(${side === 'left' ? -14 : 14}deg) scale(${0.8 + op * 0.2})`,
      border: `3px solid ${color}`, color, borderRadius: 12, padding: '6px 14px',
      fontFamily: 'var(--mono)', fontWeight: 700, fontSize: 22, letterSpacing: '0.04em',
      opacity: op, pointerEvents: 'none', background: '#ffffffcc',
    }}>{text}</div>
  );
}

// ── The Discover screen ──────────────────────────────────────
function Discover({ mode, setMode, cardStyle, applyFlow, onApply, onOpen, toast }) {
  const [tIdx, setTIdx] = dUseState(0);
  const [pIdx, setPIdx] = dUseState(0);
  const [fly, setFly] = dUseState({ dir: 'right', n: 0 });
  const [confirm, setConfirm] = dUseState(null);
  const [note, setNote] = dUseState('');

  const deck = mode === 'tasks' ? DM.TASKS : DM.PEOPLE;
  const idx = mode === 'tasks' ? tIdx : pIdx;
  const setIdx = mode === 'tasks' ? setTIdx : setPIdx;
  const item = deck[idx];

  const advance = () => { setIdx(idx + 1); setFly({ dir: 'right', n: 0 }); };
  const doLeft = () => { advance(); };
  const doApply = (it) => { advance(); onApply(it, mode); };
  const doRight = () => {
    if (applyFlow === 'tap') { toast({ text: 'Saved to your interested list', icon: 'heart' }); advance(); }
    else { doApply(item); }
  };
  const requestConfirm = () => { setNote(''); setConfirm(item); };
  const sendConfirm = () => { const it = confirm; setConfirm(null); doApply(it); };

  const undo = () => { if (idx > 0) setIdx(idx - 1); };
  const visible = deck.slice(idx, idx + 3);

  return (
    <div style={{ height: '100%', display: 'flex', flexDirection: 'column', background: 'var(--bg)' }}>
      {/* header + toggle */}
      <div style={{ padding: '58px 20px 8px', flexShrink: 0 }}>
        <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: 14 }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: 9 }}>
            <Logo size={30} />
            <span style={{ fontSize: 20, fontWeight: 800, letterSpacing: '-0.03em', color: 'var(--ink)' }}>Discover</span>
          </div>
          <button style={iconBtn}><UI.Icon name="sliders" size={20} stroke="var(--ink-2)" /></button>
        </div>
        <Toggle mode={mode} setMode={setMode} />
      </div>

      {/* deck */}
      <div style={{ flex: 1, position: 'relative', padding: '10px 20px 0' }}>
        {item ? (
          <div style={{ position: 'relative', width: '100%', height: '100%', maxHeight: 470 }}>
            {visible.map((c, i) => i === 0 ? null : (
              <div key={c.id} style={{
                position: 'absolute', inset: 0, zIndex: 5 - i,
                transform: `translateY(${i * 12}px) scale(${1 - i * 0.04})`,
                opacity: i === 2 ? 0.5 : 1, transition: 'transform .3s, opacity .3s',
                filter: 'saturate(.96)',
              }}>{renderCard(c, cardStyle)}</div>
            ))}
            <TopCard key={item.id} item={item} style={cardStyle} applyFlow={applyFlow}
              onLeft={doLeft} onRight={doRight} onConfirm={requestConfirm}
              onOpen={() => onOpen(item, mode)}
              fly={fly} />
          </div>
        ) : <EmptyDeck onReset={() => setIdx(0)} mode={mode} />}
      </div>

      {/* action bar */}
      {item && (
        <div style={{ padding: '14px 24px 16px', flexShrink: 0 }}>
          {applyFlow === 'tap' ? (
            <div style={{ display: 'flex', alignItems: 'center', gap: 14 }}>
              <ActionBtn kind="skip" onClick={() => setFly({ dir: 'left', n: fly.n + 1 })} />
              <UI.Btn full size="lg" icon="check" onClick={requestConfirm} style={{ flex: 1 }}>Apply now</UI.Btn>
              <ActionBtn kind="save" onClick={doRight} />
            </div>
          ) : (
            <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 22 }}>
              <ActionBtn kind="undo" onClick={undo} disabled={idx === 0} />
              <ActionBtn kind="skip" big onClick={() => setFly({ dir: 'left', n: fly.n + 1 })} />
              <ActionBtn kind="apply" big onClick={() => applyFlow === 'confirm' ? requestConfirm() : setFly({ dir: 'right', n: fly.n + 1 })} />
              <ActionBtn kind="open" onClick={() => onOpen(item, mode)} />
            </div>
          )}
        </div>
      )}

      {/* confirm sheet */}
      <UI.Sheet open={!!confirm} onClose={() => setConfirm(null)}>
        {confirm && (
          <div>
            <div style={{ display: 'flex', alignItems: 'center', gap: 13, marginBottom: 16 }}>
              <UI.Avatar data={confirm.avatar} size={50} />
              <div>
                <div style={{ fontWeight: 800, fontSize: 17, color: 'var(--ink)' }}>
                  {confirm.kind === 'task' ? `Apply to ${confirm.project}` : `Reach out to ${confirm.name.split(' ')[0]}`}</div>
                <div style={{ fontSize: 13.5, color: 'var(--ink-2)' }}>
                  {confirm.kind === 'task' ? confirm.title : confirm.role}</div>
              </div>
            </div>
            <UI.Label style={{ marginBottom: 8 }}>Add a note (optional)</UI.Label>
            <textarea value={note} onChange={e => setNote(e.target.value)} rows={3}
              placeholder={confirm.kind === 'task' ? 'Why you\u2019re a great fit…' : 'Say hi and what you\u2019d build together…'}
              style={{
                width: '100%', boxSizing: 'border-box', padding: '13px 15px', borderRadius: 14,
                border: '1.5px solid var(--line)', fontSize: 14.5, fontFamily: 'var(--sans)',
                resize: 'none', outline: 'none', color: 'var(--ink)',
              }}
              onFocus={e => e.target.style.borderColor = 'var(--accent)'}
              onBlur={e => e.target.style.borderColor = 'var(--line)'} />
            <div style={{ display: 'flex', gap: 10, marginTop: 16 }}>
              <UI.Btn variant="outline" onClick={() => setConfirm(null)} style={{ flex: 1 }}>Cancel</UI.Btn>
              <UI.Btn icon="send" onClick={sendConfirm} style={{ flex: 2 }}>Send application</UI.Btn>
            </div>
          </div>
        )}
      </UI.Sheet>
    </div>
  );
}

function Toggle({ mode, setMode }) {
  return (
    <div style={{ position: 'relative', display: 'flex', background: 'var(--surface-2)', borderRadius: 14, padding: 4 }}>
      <div style={{
        position: 'absolute', top: 4, bottom: 4, left: mode === 'tasks' ? 4 : '50%',
        width: 'calc(50% - 4px)', background: '#fff', borderRadius: 11,
        boxShadow: '0 2px 8px rgba(15,26,22,.1)', transition: 'left .26s cubic-bezier(.3,.8,.3,1)',
      }} />
      {[['tasks', 'Find tasks', 'briefcase'], ['people', 'Find people', 'user']].map(([k, label, ic]) => (
        <button key={k} onClick={() => setMode(k)} style={{
          flex: 1, position: 'relative', zIndex: 1, padding: '11px 0', border: 'none', background: 'none',
          cursor: 'pointer', display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 8,
          fontWeight: 700, fontSize: 14.5, fontFamily: 'var(--sans)',
          color: mode === k ? 'var(--ink)' : 'var(--ink-3)', transition: 'color .2s',
        }}><UI.Icon name={ic} size={18} stroke={mode === k ? 'var(--accent)' : 'var(--ink-3)'} />{label}</button>
      ))}
    </div>
  );
}

function ActionBtn({ kind, onClick, big, disabled }) {
  const map = {
    skip:  { icon: 'x', stroke: '#8A97A0', bg: '#fff', bd: 'var(--line)' },
    apply: { icon: 'check', stroke: '#fff', bg: 'var(--accent)', bd: 'var(--accent)' },
    undo:  { icon: 'arrowLeft', stroke: 'var(--ink-3)', bg: '#fff', bd: 'var(--line)' },
    open:  { icon: 'layers', stroke: 'var(--ink-3)', bg: '#fff', bd: 'var(--line)' },
    save:  { icon: 'heart', stroke: 'var(--accent-ink)', bg: 'var(--accent-soft)', bd: 'var(--accent-soft)' },
  }[kind];
  const sz = big ? 64 : 48;
  return (
    <button onClick={disabled ? undefined : onClick} style={{
      width: sz, height: sz, borderRadius: 999, flexShrink: 0,
      border: `1.5px solid ${map.bd}`, background: map.bg, cursor: disabled ? 'default' : 'pointer',
      display: 'flex', alignItems: 'center', justifyContent: 'center', opacity: disabled ? 0.4 : 1,
      boxShadow: kind === 'apply' ? '0 10px 22px -8px var(--accent)' : '0 4px 12px rgba(15,26,22,.06)',
      transition: 'transform .12s', WebkitTapHighlightColor: 'transparent',
    }}
      onPointerDown={e => { if (!disabled) e.currentTarget.style.transform = 'scale(.9)'; }}
      onPointerUp={e => e.currentTarget.style.transform = 'scale(1)'}
      onPointerLeave={e => e.currentTarget.style.transform = 'scale(1)'}>
      <UI.Icon name={map.icon} size={big ? 28 : 20} stroke={map.stroke} sw={2.3} fill={kind === 'save' ? map.stroke : 'none'} />
    </button>
  );
}

function EmptyDeck({ onReset, mode }) {
  return (
    <div style={{ height: '100%', display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', textAlign: 'center', padding: '0 30px', gap: 14 }}>
      <div style={{ width: 76, height: 76, borderRadius: 24, background: 'var(--accent-soft)', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
        <UI.Icon name="sparkle" size={38} stroke="var(--accent)" />
      </div>
      <div style={{ fontSize: 21, fontWeight: 800, color: 'var(--ink)', letterSpacing: '-0.02em' }}>You're all caught up</div>
      <p style={{ color: 'var(--ink-2)', fontSize: 15, margin: 0, lineHeight: 1.5 }}>
        No more {mode === 'tasks' ? 'open tasks' : 'people'} matching your skills right now. Check back soon or widen your filters.</p>
      <UI.Btn variant="ghost" onClick={onReset} icon="arrowLeft" style={{ marginTop: 6 }}>Review again</UI.Btn>
    </div>
  );
}

const iconBtn = {
  width: 40, height: 40, borderRadius: 999, border: '1.5px solid var(--line)', background: '#fff',
  display: 'flex', alignItems: 'center', justifyContent: 'center', cursor: 'pointer', padding: 0,
  WebkitTapHighlightColor: 'transparent',
};

Object.assign(window, { Discover, renderCard, MatchRing, Meta, CardShell, PlaceholderArt, iconBtn });
