// ui.jsx — DevMatch shared primitives + icon set. Exposes window.UI
const { useState, useEffect, useRef } = React;

// ── Icons (simple line glyphs) ───────────────────────────────
function Icon({ name, size = 24, stroke = 'currentColor', fill = 'none', sw = 1.9, style }) {
  const p = { fill: 'none', stroke, strokeWidth: sw, strokeLinecap: 'round', strokeLinejoin: 'round' };
  const paths = {
    compass: <g {...p}><circle cx="12" cy="12" r="9" /><path d="M15.5 8.5l-2 5-5 2 2-5z" /></g>,
    chat: <g {...p}><path d="M21 11.5a8.5 8.5 0 0 1-12.4 7.5L3 21l2-5.6A8.5 8.5 0 1 1 21 11.5z" /></g>,
    user: <g {...p}><circle cx="12" cy="8" r="4" /><path d="M4 20c1.5-3.5 4.5-5 8-5s6.5 1.5 8 5" /></g>,
    plus: <g {...p}><path d="M12 5v14M5 12h14" /></g>,
    check: <g {...p}><path d="M5 12.5l4.5 4.5L19 7" /></g>,
    x: <g {...p}><path d="M6 6l12 12M18 6L6 18" /></g>,
    arrowLeft: <g {...p}><path d="M15 5l-7 7 7 7" /></g>,
    arrowRight: <g {...p}><path d="M9 5l7 7-7 7" /></g>,
    bolt: <g {...p}><path d="M13 3L5 13h6l-1 8 8-10h-6z" /></g>,
    pin: <g {...p}><path d="M12 21s7-5.5 7-11a7 7 0 1 0-14 0c0 5.5 7 11 7 11z" /><circle cx="12" cy="10" r="2.4" /></g>,
    clock: <g {...p}><circle cx="12" cy="12" r="9" /><path d="M12 7.5V12l3 2" /></g>,
    star: <g {...p}><path d="M12 4l2.4 4.9 5.4.8-3.9 3.8.9 5.4-4.8-2.5-4.8 2.5.9-5.4L4.2 9.7l5.4-.8z" /></g>,
    send: <g {...p}><path d="M21 4L3 11l6 2.5L12 20l3-9z" /><path d="M9 13.5L21 4" /></g>,
    search: <g {...p}><circle cx="11" cy="11" r="7" /><path d="M20 20l-4-4" /></g>,
    sliders: <g {...p}><path d="M4 6h10M18 6h2M4 12h4M12 12h8M4 18h12M18 18h2" /><circle cx="16" cy="6" r="2" fill={stroke} /><circle cx="10" cy="12" r="2" fill={stroke} /><circle cx="16" cy="18" r="2" fill={stroke} /></g>,
    briefcase: <g {...p}><rect x="3" y="7" width="18" height="13" rx="2.5" /><path d="M8 7V5.5A1.5 1.5 0 0 1 9.5 4h5A1.5 1.5 0 0 1 16 5.5V7M3 12h18" /></g>,
    layers: <g {...p}><path d="M12 4l8 4-8 4-8-4 8-4z" /><path d="M4 12l8 4 8-4M4 16l8 4 8-4" /></g>,
    bell: <g {...p}><path d="M6 9a6 6 0 1 1 12 0c0 4 1.5 5 2 6H4c.5-1 2-2 2-6z" /><path d="M10 20a2 2 0 0 0 4 0" /></g>,
    heart: <g {...p}><path d="M12 20S4 14.5 4 9.2A4.2 4.2 0 0 1 12 7a4.2 4.2 0 0 1 8 2.2C20 14.5 12 20 12 20z" /></g>,
    edit: <g {...p}><path d="M4 20h4L19 9l-4-4L4 16z" /><path d="M14 6l4 4" /></g>,
    code: <g {...p}><path d="M9 8l-4 4 4 4M15 8l4 4-4 4" /></g>,
    rocket: <g {...p}><path d="M12 3c3 1 5 4 5 8l-2 4H9l-2-4c0-4 2-7 5-8z" /><circle cx="12" cy="9" r="1.6" /><path d="M9 15l-2 4 3-1M15 15l2 4-3-1" /></g>,
    sparkle: <g {...p}><path d="M12 4l1.6 4.4L18 10l-4.4 1.6L12 16l-1.6-4.4L6 10l4.4-1.6z" /></g>,
  };
  return (
    <svg width={size} height={size} viewBox="0 0 24 24" fill={fill} style={style}>
      {paths[name] || null}
    </svg>
  );
}

// ── Avatar ───────────────────────────────────────────────────
function Avatar({ data, size = 48, ring = false }) {
  return (
    <div style={{
      width: size, height: size, borderRadius: size, flexShrink: 0,
      background: data.bg, color: data.fg,
      display: 'flex', alignItems: 'center', justifyContent: 'center',
      fontWeight: 700, fontSize: size * 0.34, letterSpacing: '-0.02em',
      boxShadow: ring ? `0 0 0 3px #fff, 0 0 0 5px ${data.fg}22` : 'none',
      fontFamily: 'var(--mono)',
    }}>{data.initials}</div>
  );
}

// ── Skill / meta tag ─────────────────────────────────────────
function Tag({ children, tone = 'default', size = 'md' }) {
  const tones = {
    default: { bg: 'var(--surface-2)', fg: 'var(--ink-2)', bd: 'transparent' },
    accent:  { bg: 'var(--accent-soft)', fg: 'var(--accent-ink)', bd: 'transparent' },
    outline: { bg: 'transparent', fg: 'var(--ink-2)', bd: 'var(--line)' },
    light:   { bg: 'rgba(255,255,255,.16)', fg: '#fff', bd: 'transparent' },
  };
  const t = tones[tone] || tones.default;
  const pad = size === 'sm' ? '4px 9px' : '6px 12px';
  const fs = size === 'sm' ? 12 : 13;
  return (
    <span style={{
      display: 'inline-flex', alignItems: 'center', gap: 5,
      padding: pad, borderRadius: 999, background: t.bg, color: t.fg,
      border: `1.5px solid ${t.bd}`, fontFamily: 'var(--mono)',
      fontSize: fs, fontWeight: 500, lineHeight: 1, whiteSpace: 'nowrap',
    }}>{children}</span>
  );
}

// ── Buttons ──────────────────────────────────────────────────
function Btn({ children, onClick, variant = 'primary', size = 'lg', full, disabled, style, icon }) {
  const sizes = {
    lg: { padding: '15px 22px', fontSize: 16, radius: 16 },
    md: { padding: '11px 18px', fontSize: 15, radius: 13 },
    sm: { padding: '8px 14px', fontSize: 13.5, radius: 11 },
  }[size];
  const variants = {
    primary: { background: 'var(--accent)', color: '#fff', border: 'none',
      boxShadow: disabled ? 'none' : '0 8px 20px -8px var(--accent)' },
    dark: { background: 'var(--ink)', color: '#fff', border: 'none' },
    ghost: { background: 'var(--surface-2)', color: 'var(--ink)', border: 'none' },
    outline: { background: '#fff', color: 'var(--ink)', border: '1.5px solid var(--line)' },
  }[variant];
  return (
    <button onClick={disabled ? undefined : onClick} disabled={disabled} style={{
      display: 'inline-flex', alignItems: 'center', justifyContent: 'center', gap: 9,
      width: full ? '100%' : undefined, cursor: disabled ? 'default' : 'pointer',
      padding: sizes.padding, fontSize: sizes.fontSize, borderRadius: sizes.radius,
      fontWeight: 600, fontFamily: 'var(--sans)', letterSpacing: '-0.01em',
      opacity: disabled ? 0.4 : 1, transition: 'transform .12s, opacity .12s',
      WebkitTapHighlightColor: 'transparent', ...variants, ...style,
    }}
      onPointerDown={e => { if (!disabled) e.currentTarget.style.transform = 'scale(.97)'; }}
      onPointerUp={e => { e.currentTarget.style.transform = 'scale(1)'; }}
      onPointerLeave={e => { e.currentTarget.style.transform = 'scale(1)'; }}
    >{icon && <Icon name={icon} size={18} sw={2.1} />}{children}</button>
  );
}

// ── Progress dots / bar ──────────────────────────────────────
function Progress({ step, total }) {
  return (
    <div style={{ display: 'flex', gap: 6, alignItems: 'center' }}>
      {Array.from({ length: total }).map((_, i) => (
        <div key={i} style={{
          height: 6, borderRadius: 999, flex: i === step ? 2.2 : 1,
          background: i <= step ? 'var(--accent)' : 'var(--surface-2)',
          transition: 'all .35s cubic-bezier(.2,.8,.2,1)',
        }} />
      ))}
    </div>
  );
}

// ── Bottom sheet ─────────────────────────────────────────────
function Sheet({ open, onClose, children, height }) {
  const [mounted, setMounted] = useState(open);
  useEffect(() => { if (open) setMounted(true); }, [open]);
  if (!mounted) return null;
  return (
    <div style={{
      position: 'absolute', inset: 0, zIndex: 80, display: 'flex', alignItems: 'flex-end',
    }}>
      <div onClick={onClose} style={{
        position: 'absolute', inset: 0, background: 'rgba(15,26,22,.42)',
        opacity: open ? 1 : 0, transition: 'opacity .28s',
        backdropFilter: 'blur(2px)',
      }} onTransitionEnd={() => { if (!open) setMounted(false); }} />
      <div style={{
        position: 'relative', width: '100%', background: 'var(--surface)',
        borderRadius: '28px 28px 0 0', padding: '10px 22px 30px',
        height, boxShadow: '0 -20px 50px rgba(15,26,22,.18)',
        transform: open ? 'translateY(0)' : 'translateY(100%)',
        transition: 'transform .34s cubic-bezier(.2,.85,.25,1)',
        maxHeight: '88%', overflowY: 'auto',
      }}>
        <div style={{ width: 40, height: 5, borderRadius: 999, background: 'var(--line)', margin: '0 auto 16px' }} />
        {children}
      </div>
    </div>
  );
}

// ── Toast ────────────────────────────────────────────────────
function Toast({ toast }) {
  if (!toast) return null;
  return (
    <div key={toast.key} style={{
      position: 'absolute', left: 16, right: 16, bottom: 96, zIndex: 90,
      background: 'var(--ink)', color: '#fff', borderRadius: 16,
      padding: '13px 16px', display: 'flex', alignItems: 'center', gap: 11,
      boxShadow: '0 16px 36px rgba(15,26,22,.3)', animation: 'dmToast .4s cubic-bezier(.2,.9,.2,1)',
      fontSize: 14.5, fontWeight: 500,
    }}>
      <div style={{
        width: 26, height: 26, borderRadius: 999, background: 'var(--accent)',
        display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0,
      }}><Icon name={toast.icon || 'check'} size={16} stroke="#fff" sw={2.6} /></div>
      <span>{toast.text}</span>
    </div>
  );
}

// ── Section label ────────────────────────────────────────────
function Label({ children, style }) {
  return <div style={{
    fontFamily: 'var(--mono)', fontSize: 11.5, fontWeight: 600,
    letterSpacing: '0.08em', textTransform: 'uppercase', color: 'var(--ink-3)', ...style,
  }}>{children}</div>;
}

window.UI = { Icon, Avatar, Tag, Btn, Progress, Sheet, Toast, Label };
