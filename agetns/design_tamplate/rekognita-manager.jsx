import { useState } from "react";

const COLORS = {
  brand: "#2563eb",
  brandLight: "#3b82f6",
  dark: "#0f172a",
  mid: "#1e293b",
  muted: "#64748b",
  border: "#e2e8f0",
  bg: "#f1f5f9",
  white: "#ffffff",
  success: "#10b981",
  warning: "#f59e0b",
  danger: "#ef4444",
};

const companies = [
  { id: 1, name: "Промбуд ТОВ", plan: "cloud", pages: 1240, limit: 2000 },
  { id: 2, name: "МедЦентр Плюс", plan: "self-hosted", pages: 834, limit: null },
  { id: 3, name: "Логістик Груп", plan: "cloud", pages: 310, limit: 500 },
];

const employees = [
  { id: 1, name: "Олексій Коваль", role: "Комірник", dept: "Склад", status: "active", docs: ["Накладні", "Акти"] },
  { id: 2, name: "Марина Петрова", role: "Бухгалтер", dept: "Бухгалтерія", status: "active", docs: ["Рахунки", "Договори"] },
  { id: 3, name: "Іван Сидоренко", role: "Медпрацівник", dept: "HR/Медицина", status: "inactive", docs: ["Медичні довідки"] },
  { id: 4, name: "Тетяна Мороз", role: "Логіст", dept: "Логістика", status: "active", docs: ["Накладні"] },
];

const docTypes = [
  { id: 1, name: "Накладні", icon: "📦", integration: "1С/БАС", fields: 7, workers: 12, color: "#3b82f6" },
  { id: 2, name: "Медичні довідки", icon: "🏥", integration: "MedCRM", fields: 5, workers: 3, color: "#10b981" },
  { id: 3, name: "Договори", icon: "📋", integration: "DocFlow", fields: 9, workers: 6, color: "#8b5cf6" },
  { id: 4, name: "Рахунки-фактури", icon: "💰", integration: "1С/БАС", fields: 6, workers: 8, color: "#f59e0b" },
  { id: 5, name: "Паспорти", icon: "🪪", integration: "HR CRM", fields: 4, workers: 2, color: "#ef4444" },
];

const templates = [
  { id: 1, docType: "Накладні", fields: ["Назва товару", "Артикул", "Кількість", "Ціна", "Сума", "Дата", "Постачальник"] },
  { id: 2, docType: "Медичні довідки", fields: ["ПІБ", "Дата народження", "Діагноз", "Лікар", "Дата видачі"] },
];

const navItems = [
  { id: "dashboard", label: "Дашборд", icon: DashIcon },
  { id: "team", label: "Команда", icon: TeamIcon },
  { id: "doctypes", label: "Типи документів", icon: DocIcon },
  { id: "templates", label: "Шаблони", icon: TemplateIcon },
  { id: "integrations", label: "Інтеграції", icon: IntegIcon },
];

function DashIcon({ active }) {
  return (
    <svg width="18" height="18" fill="none" viewBox="0 0 24 24">
      <rect x="3" y="3" width="7" height="7" rx="2" fill={active ? "#fff" : COLORS.muted} />
      <rect x="14" y="3" width="7" height="7" rx="2" fill={active ? "#fff" : COLORS.muted} />
      <rect x="3" y="14" width="7" height="7" rx="2" fill={active ? "#fff" : COLORS.muted} />
      <rect x="14" y="14" width="7" height="7" rx="2" fill={active ? "rgba(255,255,255,0.5)" : "rgba(100,116,139,0.4)"} />
    </svg>
  );
}
function TeamIcon({ active }) {
  return (
    <svg width="18" height="18" fill="none" viewBox="0 0 24 24">
      <circle cx="9" cy="7" r="4" fill={active ? "#fff" : COLORS.muted} />
      <path d="M2 21c0-4 3.134-7 7-7s7 3 7 7" stroke={active ? "#fff" : COLORS.muted} strokeWidth="2" strokeLinecap="round" />
      <circle cx="19" cy="8" r="3" fill={active ? "rgba(255,255,255,0.6)" : "rgba(100,116,139,0.5)"} />
      <path d="M22 21c0-3-1.8-5.5-4-6" stroke={active ? "rgba(255,255,255,0.6)" : "rgba(100,116,139,0.5)"} strokeWidth="2" strokeLinecap="round" />
    </svg>
  );
}
function DocIcon({ active }) {
  return (
    <svg width="18" height="18" fill="none" viewBox="0 0 24 24">
      <path d="M14 2H6a2 2 0 00-2 2v16a2 2 0 002 2h12a2 2 0 002-2V8l-6-6z" fill={active ? "#fff" : COLORS.muted} />
      <path d="M14 2v6h6" fill={active ? "rgba(37,99,235,0.5)" : "rgba(100,116,139,0.3)"} />
      <path d="M8 13h8M8 17h5" stroke={active ? COLORS.brand : "#f1f5f9"} strokeWidth="1.5" strokeLinecap="round" />
    </svg>
  );
}
function TemplateIcon({ active }) {
  return (
    <svg width="18" height="18" fill="none" viewBox="0 0 24 24">
      <rect x="3" y="3" width="18" height="4" rx="1.5" fill={active ? "#fff" : COLORS.muted} />
      <rect x="3" y="10" width="8" height="11" rx="1.5" fill={active ? "#fff" : COLORS.muted} />
      <rect x="13" y="10" width="8" height="5" rx="1.5" fill={active ? "rgba(255,255,255,0.6)" : "rgba(100,116,139,0.5)"} />
      <rect x="13" y="18" width="8" height="3" rx="1.5" fill={active ? "rgba(255,255,255,0.4)" : "rgba(100,116,139,0.3)"} />
    </svg>
  );
}
function IntegIcon({ active }) {
  return (
    <svg width="18" height="18" fill="none" viewBox="0 0 24 24">
      <circle cx="5" cy="12" r="3" fill={active ? "#fff" : COLORS.muted} />
      <circle cx="19" cy="6" r="3" fill={active ? "#fff" : COLORS.muted} />
      <circle cx="19" cy="18" r="3" fill={active ? "rgba(255,255,255,0.6)" : "rgba(100,116,139,0.5)"} />
      <path d="M8 12h4l3-5M8 12h4l3 5" stroke={active ? "rgba(255,255,255,0.7)" : "rgba(100,116,139,0.4)"} strokeWidth="1.5" strokeLinecap="round" />
    </svg>
  );
}

function Badge({ children, color = COLORS.brand }) {
  return (
    <span style={{ background: color + "18", color, fontSize: 11, fontWeight: 700, padding: "3px 10px", borderRadius: 100, letterSpacing: 0.3 }}>
      {children}
    </span>
  );
}

// LOGIN PAGE
function LoginPage({ onLogin }) {
  return (
    <div style={{
      minHeight: "100vh",
      background: COLORS.dark,
      display: "flex",
      alignItems: "center",
      justifyContent: "center",
      fontFamily: "'DM Sans', 'Segoe UI', sans-serif",
      position: "relative",
      overflow: "hidden",
    }}>
      <div style={{ position: "absolute", top: -120, left: -120, width: 480, height: 480, borderRadius: "50%", background: "radial-gradient(circle, rgba(37,99,235,0.18) 0%, transparent 70%)", pointerEvents: "none" }} />
      <div style={{ position: "absolute", bottom: -80, right: -80, width: 360, height: 360, borderRadius: "50%", background: "radial-gradient(circle, rgba(59,130,246,0.12) 0%, transparent 70%)", pointerEvents: "none" }} />
      <div style={{ position: "absolute", inset: 0, backgroundImage: "linear-gradient(rgba(255,255,255,0.03) 1px, transparent 1px), linear-gradient(90deg, rgba(255,255,255,0.03) 1px, transparent 1px)", backgroundSize: "48px 48px", pointerEvents: "none" }} />

      <div style={{ width: 420, position: "relative", zIndex: 1 }}>
        <div style={{ textAlign: "center", marginBottom: 40 }}>
          <div style={{ display: "inline-flex", alignItems: "center", gap: 10, marginBottom: 8 }}>
            <div style={{ width: 40, height: 40, borderRadius: 12, background: COLORS.brand, display: "flex", alignItems: "center", justifyContent: "center" }}>
              <svg width="22" height="22" fill="none" viewBox="0 0 24 24">
                <path d="M9 3H5a2 2 0 00-2 2v4m6-6h10a2 2 0 012 2v4M9 3v18m0 0h10a2 2 0 002-2v-4M9 21H5a2 2 0 01-2-2v-4m0 0h18" stroke="#fff" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" />
              </svg>
            </div>
            <div style={{ textAlign: "left" }}>
              <div style={{ fontSize: 20, fontWeight: 800, color: "#fff", letterSpacing: -0.5 }}>Re::kognita</div>
              <div style={{ fontSize: 10, color: "rgba(255,255,255,0.35)", letterSpacing: 1.5, textTransform: "uppercase" }}>Document Restructuring</div>
            </div>
          </div>
          <div style={{ fontSize: 14, color: "rgba(255,255,255,0.45)", marginTop: 12 }}>Вхід до панелі менеджера</div>
        </div>

        <div style={{ background: "rgba(255,255,255,0.05)", backdropFilter: "blur(20px)", border: "1px solid rgba(255,255,255,0.1)", borderRadius: 20, padding: 36 }}>
          <div style={{ display: "flex", flexDirection: "column", gap: 12, marginBottom: 28 }}>
            <button onClick={onLogin} style={{
              background: "#fff", border: "none", borderRadius: 12, padding: "14px",
              display: "flex", alignItems: "center", justifyContent: "center", gap: 10,
              cursor: "pointer", fontSize: 14, fontWeight: 700, color: COLORS.dark,
            }}>
              <svg width="20" height="20" viewBox="0 0 24 24">
                <path fill="#4285F4" d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z"/>
                <path fill="#34A853" d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z"/>
                <path fill="#FBBC05" d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.07H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.93l2.85-2.22.81-.62z"/>
                <path fill="#EA4335" d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.07l3.66 2.84c.87-2.6 3.3-4.53 6.16-4.53z"/>
              </svg>
              Увійти через Google
            </button>

            <button onClick={onLogin} style={{
              background: "#000", border: "1px solid rgba(255,255,255,0.15)", borderRadius: 12, padding: "14px",
              display: "flex", alignItems: "center", justifyContent: "center", gap: 10,
              cursor: "pointer", fontSize: 14, fontWeight: 700, color: "#fff",
            }}>
              <svg width="20" height="20" viewBox="0 0 24 24" fill="white">
                <path d="M18.71 19.5c-.83 1.24-1.71 2.45-3.05 2.47-1.34.03-1.77-.79-3.29-.79-1.53 0-2 .77-3.27.82-1.31.05-2.3-1.32-3.14-2.53C4.25 17 2.94 12.45 4.7 9.39c.87-1.52 2.43-2.48 4.12-2.51 1.28-.02 2.5.87 3.29.87.78 0 2.26-1.07 3.8-.91.65.03 2.47.26 3.64 1.98-.09.06-2.17 1.28-2.15 3.81.03 3.02 2.65 4.03 2.68 4.04-.03.07-.42 1.44-1.38 2.83M13 3.5c.73-.83 1.94-1.46 2.94-1.5.13 1.17-.34 2.35-1.04 3.19-.69.85-1.83 1.51-2.95 1.42-.15-1.15.41-2.35 1.05-3.11z"/>
              </svg>
              Увійти через Apple
            </button>
          </div>

          <div style={{ display: "flex", alignItems: "center", gap: 14, marginBottom: 24 }}>
            <div style={{ flex: 1, height: 1, background: "rgba(255,255,255,0.1)" }} />
            <span style={{ fontSize: 12, color: "rgba(255,255,255,0.3)" }}>або через email</span>
            <div style={{ flex: 1, height: 1, background: "rgba(255,255,255,0.1)" }} />
          </div>

          <div style={{ display: "flex", flexDirection: "column", gap: 12, marginBottom: 16 }}>
            <input placeholder="Email" style={{
              background: "rgba(255,255,255,0.06)", border: "1px solid rgba(255,255,255,0.12)", borderRadius: 12,
              padding: "14px 16px", color: "#fff", fontSize: 14, outline: "none", width: "100%", boxSizing: "border-box", fontFamily: "inherit",
            }} />
            <input placeholder="Пароль" type="password" style={{
              background: "rgba(255,255,255,0.06)", border: "1px solid rgba(255,255,255,0.12)", borderRadius: 12,
              padding: "14px 16px", color: "#fff", fontSize: 14, outline: "none", width: "100%", boxSizing: "border-box", fontFamily: "inherit",
            }} />
          </div>

          <div style={{ textAlign: "right", marginBottom: 20 }}>
            <span style={{ fontSize: 12, color: COLORS.brandLight, cursor: "pointer" }}>Забули пароль?</span>
          </div>

          <button onClick={onLogin} style={{
            background: COLORS.brand, border: "none", borderRadius: 12, padding: "14px",
            width: "100%", fontSize: 14, fontWeight: 700, color: "#fff", cursor: "pointer",
            boxShadow: "0 4px 20px rgba(37,99,235,0.5)",
          }}>
            Увійти
          </button>
        </div>

        <div style={{ textAlign: "center", marginTop: 20, fontSize: 12, color: "rgba(255,255,255,0.25)" }}>
          Rekognita Manager · Захищений вхід
        </div>
      </div>
    </div>
  );
}

// COMPANY SWITCHER
function CompanySwitcher({ currentCompany, onSwitch }) {
  const [open, setOpen] = useState(false);
  const c = currentCompany;
  const pct = c.limit ? Math.round((c.pages / c.limit) * 100) : null;

  return (
    <div style={{ position: "relative", marginBottom: 20 }}>
      <button onClick={() => setOpen(!open)} style={{
        width: "100%", background: "rgba(255,255,255,0.06)",
        border: `1px solid ${open ? "rgba(59,130,246,0.5)" : "rgba(255,255,255,0.08)"}`,
        borderRadius: 12, padding: "10px 12px", cursor: "pointer", textAlign: "left",
        display: "flex", alignItems: "center", gap: 8,
      }}>
        <div style={{ flex: 1, minWidth: 0 }}>
          <div style={{ fontSize: 10, color: "rgba(255,255,255,0.35)", textTransform: "uppercase", letterSpacing: 0.8, marginBottom: 2 }}>Компанія</div>
          <div style={{ fontSize: 13, fontWeight: 700, color: "#fff", whiteSpace: "nowrap", overflow: "hidden", textOverflow: "ellipsis" }}>{c.name}</div>
          <div style={{ fontSize: 10, color: c.plan === "cloud" ? COLORS.brandLight : COLORS.success, marginTop: 2, fontWeight: 600 }}>
            {c.plan === "cloud" ? `☁ Хмара · ${c.pages} / ${c.limit} стор.` : "🏢 Self-Hosted"}
          </div>
        </div>
        <svg width="14" height="14" fill="none" viewBox="0 0 24 24" style={{ flexShrink: 0, transform: open ? "rotate(180deg)" : "none", transition: "transform 0.2s" }}>
          <path d="M6 9l6 6 6-6" stroke="rgba(255,255,255,0.4)" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" />
        </svg>
      </button>

      {c.plan === "cloud" && pct !== null && (
        <div style={{ marginTop: 5, height: 3, borderRadius: 100, background: "rgba(255,255,255,0.08)" }}>
          <div style={{ height: 3, borderRadius: 100, background: pct > 85 ? COLORS.warning : COLORS.brandLight, width: `${pct}%`, transition: "width 0.5s" }} />
        </div>
      )}

      {open && (
        <div style={{
          position: "absolute", top: "calc(100% + 8px)", left: 0, right: 0,
          background: COLORS.mid, border: "1px solid rgba(255,255,255,0.1)", borderRadius: 14,
          overflow: "hidden", zIndex: 100, boxShadow: "0 12px 40px rgba(0,0,0,0.5)",
        }}>
          <div style={{ padding: "10px 12px 6px", fontSize: 10, color: "rgba(255,255,255,0.3)", textTransform: "uppercase", letterSpacing: 0.8 }}>Мої компанії</div>
          {companies.map(comp => (
            <div key={comp.id} onClick={() => { onSwitch(comp); setOpen(false); }} style={{
              padding: "10px 12px", cursor: "pointer", display: "flex", alignItems: "center", gap: 10,
              background: comp.id === c.id ? "rgba(37,99,235,0.2)" : "transparent",
            }}>
              <div style={{ width: 28, height: 28, borderRadius: 8, background: comp.id === c.id ? COLORS.brand : "rgba(255,255,255,0.1)", display: "flex", alignItems: "center", justifyContent: "center", fontSize: 11, fontWeight: 700, color: "#fff", flexShrink: 0 }}>
                {comp.name[0]}
              </div>
              <div style={{ flex: 1, minWidth: 0 }}>
                <div style={{ fontSize: 12, fontWeight: 700, color: "#fff", whiteSpace: "nowrap", overflow: "hidden", textOverflow: "ellipsis" }}>{comp.name}</div>
                <div style={{ fontSize: 10, color: comp.plan === "cloud" ? COLORS.brandLight : COLORS.success }}>
                  {comp.plan === "cloud" ? `☁ ${comp.pages} / ${comp.limit} стор.` : "🏢 Self-Hosted"}
                </div>
              </div>
              {comp.id === c.id && (
                <svg width="14" height="14" fill="none" viewBox="0 0 24 24"><path d="M20 6L9 17l-5-5" stroke={COLORS.brandLight} strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round"/></svg>
              )}
            </div>
          ))}
          <div style={{ padding: "8px 12px", borderTop: "1px solid rgba(255,255,255,0.06)" }}>
            <div style={{ fontSize: 12, color: "rgba(255,255,255,0.4)", cursor: "pointer", display: "flex", alignItems: "center", gap: 6, padding: "4px 0" }}>
              <span style={{ fontSize: 14 }}>+</span> Додати компанію
            </div>
          </div>
        </div>
      )}
    </div>
  );
}

// DASHBOARD
function StatCard({ value, label, delta }) {
  return (
    <div style={{ background: COLORS.white, borderRadius: 16, padding: "20px 24px", border: `1px solid ${COLORS.border}`, flex: 1, minWidth: 0 }}>
      <div style={{ fontSize: 28, fontWeight: 800, color: COLORS.dark, fontFamily: "Georgia, serif", letterSpacing: -1 }}>{value}</div>
      <div style={{ fontSize: 12, color: COLORS.muted, marginTop: 4, fontWeight: 500 }}>{label}</div>
      {delta && <div style={{ fontSize: 11, color: COLORS.success, marginTop: 8, fontWeight: 600 }}>↑ {delta}</div>}
    </div>
  );
}

function Dashboard({ company }) {
  const pct = company.limit ? Math.round((company.pages / company.limit) * 100) : null;
  return (
    <div>
      <div style={{ marginBottom: 28 }}>
        <div style={{ fontSize: 22, fontWeight: 800, color: COLORS.dark, fontFamily: "Georgia, serif" }}>Добрий день, Андрію 👋</div>
        <div style={{ fontSize: 13, color: COLORS.muted, marginTop: 4 }}>Ось що відбувається у компанії сьогодні</div>
      </div>

      {company.plan === "cloud" && pct !== null && (
        <div style={{ background: pct > 85 ? "#fffbeb" : COLORS.brand + "08", border: `1px solid ${pct > 85 ? COLORS.warning + "60" : COLORS.brand + "25"}`, borderRadius: 14, padding: "14px 20px", marginBottom: 20, display: "flex", alignItems: "center", gap: 16 }}>
          <div style={{ flex: 1 }}>
            <div style={{ fontSize: 13, fontWeight: 700, color: COLORS.dark }}>
              {pct > 85 ? "⚠️ Ліміт сторінок майже вичерпано" : "☁ Хмарний план · Поточний місяць"}
            </div>
            <div style={{ fontSize: 12, color: COLORS.muted, marginTop: 2 }}>{company.pages} / {company.limit} сторінок оброблено</div>
            <div style={{ marginTop: 8, height: 5, borderRadius: 100, background: COLORS.border }}>
              <div style={{ height: 5, borderRadius: 100, background: pct > 85 ? COLORS.warning : COLORS.brand, width: `${pct}%` }} />
            </div>
          </div>
          <button style={{ background: COLORS.brand, color: "#fff", border: "none", borderRadius: 10, padding: "8px 16px", fontSize: 12, fontWeight: 700, cursor: "pointer", flexShrink: 0 }}>Поповнити</button>
        </div>
      )}
      {company.plan === "self-hosted" && (
        <div style={{ background: COLORS.success + "08", border: `1px solid ${COLORS.success}25`, borderRadius: 14, padding: "12px 20px", marginBottom: 20, display: "flex", alignItems: "center", gap: 12 }}>
          <span style={{ fontSize: 16 }}>🏢</span>
          <div style={{ fontSize: 13, fontWeight: 600, color: COLORS.dark }}>Self-Hosted · <span style={{ color: COLORS.success }}>{company.pages} стор. оброблено цього місяця</span></div>
        </div>
      )}

      <div style={{ display: "flex", gap: 16, marginBottom: 24 }}>
        <StatCard value="247" label="Документів сьогодні" delta="+18% до вчора" />
        <StatCard value="23" label="Активних співробітників" />
        <StatCard value="5" label="Типів документів" />
        <StatCard value="99.1%" label="Точність розпізнавання" />
      </div>

      <div style={{ display: "grid", gridTemplateColumns: "1.5fr 1fr", gap: 20 }}>
        <div style={{ background: COLORS.white, borderRadius: 16, border: `1px solid ${COLORS.border}`, padding: 24 }}>
          <div style={{ fontSize: 14, fontWeight: 700, color: COLORS.dark, marginBottom: 16 }}>Остання активність</div>
          {[
            { name: "Олексій Коваль", action: "завантажив Накладну №1247", time: "2 хв тому", type: "Накладні" },
            { name: "Марина Петрова", action: "завантажила Рахунок-фактуру", time: "14 хв тому", type: "Рахунки" },
            { name: "Тетяна Мороз", action: "завантажила Накладну №1246", time: "31 хв тому", type: "Накладні" },
            { name: "Іван Сидоренко", action: "завантажив Медичну довідку", time: "1 год тому", type: "Медичні" },
            { name: "Олексій Коваль", action: "завантажив Акт прийому №88", time: "2 год тому", type: "Акти" },
          ].map((item, i) => (
            <div key={i} style={{ display: "flex", alignItems: "center", gap: 12, padding: "10px 0", borderBottom: i < 4 ? `1px solid ${COLORS.bg}` : "none" }}>
              <div style={{ width: 36, height: 36, borderRadius: 10, background: COLORS.brand + "15", display: "flex", alignItems: "center", justifyContent: "center", fontSize: 12, fontWeight: 700, color: COLORS.brand, flexShrink: 0 }}>
                {item.name.split(" ").map(n => n[0]).join("")}
              </div>
              <div style={{ flex: 1, minWidth: 0 }}>
                <div style={{ fontSize: 12, fontWeight: 600, color: COLORS.dark }}>{item.name} <span style={{ fontWeight: 400, color: COLORS.muted }}>{item.action}</span></div>
                <div style={{ fontSize: 11, color: COLORS.muted, marginTop: 2 }}>{item.time}</div>
              </div>
              <Badge>{item.type}</Badge>
            </div>
          ))}
        </div>

        <div style={{ background: COLORS.white, borderRadius: 16, border: `1px solid ${COLORS.border}`, padding: 24 }}>
          <div style={{ fontSize: 14, fontWeight: 700, color: COLORS.dark, marginBottom: 16 }}>По типах документів</div>
          {[
            { name: "Накладні", pct: 52, color: COLORS.brandLight },
            { name: "Рахунки", pct: 22, color: "#f59e0b" },
            { name: "Договори", pct: 14, color: "#8b5cf6" },
            { name: "Медичні", pct: 8, color: COLORS.success },
            { name: "Паспорти", pct: 4, color: "#ef4444" },
          ].map((item, i) => (
            <div key={i} style={{ marginBottom: 14 }}>
              <div style={{ display: "flex", justifyContent: "space-between", marginBottom: 5 }}>
                <span style={{ fontSize: 12, fontWeight: 600, color: COLORS.dark }}>{item.name}</span>
                <span style={{ fontSize: 12, color: COLORS.muted }}>{item.pct}%</span>
              </div>
              <div style={{ height: 6, borderRadius: 100, background: COLORS.bg }}>
                <div style={{ height: 6, borderRadius: 100, background: item.color, width: `${item.pct}%` }} />
              </div>
            </div>
          ))}
          <div style={{ marginTop: 20, padding: "14px 16px", background: COLORS.bg, borderRadius: 12, border: `1px solid ${COLORS.border}` }}>
            <div style={{ fontSize: 11, color: COLORS.muted, marginBottom: 4 }}>Заощаджено людино-годин</div>
            <div style={{ fontSize: 24, fontWeight: 800, color: COLORS.dark, fontFamily: "Georgia, serif" }}>148 <span style={{ fontSize: 13, fontWeight: 500, color: COLORS.muted }}>цього місяця</span></div>
          </div>
        </div>
      </div>
    </div>
  );
}

// TEAM
function Team() {
  const [selected, setSelected] = useState(null);
  const [search, setSearch] = useState("");
  const filtered = employees.filter(e => e.name.toLowerCase().includes(search.toLowerCase()));
  return (
    <div style={{ display: "grid", gridTemplateColumns: "1fr 360px", gap: 20 }}>
      <div>
        <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", marginBottom: 20 }}>
          <div>
            <div style={{ fontSize: 20, fontWeight: 800, color: COLORS.dark, fontFamily: "Georgia, serif" }}>Команда</div>
            <div style={{ fontSize: 12, color: COLORS.muted }}>{employees.length} співробітників</div>
          </div>
          <button style={{ background: COLORS.brand, color: "#fff", border: "none", borderRadius: 10, padding: "10px 18px", fontSize: 13, fontWeight: 700, cursor: "pointer" }}>+ Додати</button>
        </div>
        <div style={{ background: COLORS.white, borderRadius: 12, padding: "10px 14px", border: `1px solid ${COLORS.border}`, marginBottom: 16, display: "flex", alignItems: "center", gap: 10 }}>
          <svg width="16" height="16" fill="none" viewBox="0 0 24 24"><circle cx="11" cy="11" r="8" stroke={COLORS.muted} strokeWidth="2"/><path d="M21 21l-4.35-4.35" stroke={COLORS.muted} strokeWidth="2" strokeLinecap="round"/></svg>
          <input value={search} onChange={e => setSearch(e.target.value)} placeholder="Пошук співробітника..." style={{ border: "none", outline: "none", flex: 1, fontSize: 13, color: COLORS.dark, background: "transparent" }} />
        </div>
        <div style={{ display: "flex", flexDirection: "column", gap: 10 }}>
          {filtered.map(emp => (
            <div key={emp.id} onClick={() => setSelected(emp)} style={{
              background: selected?.id === emp.id ? COLORS.brand + "08" : COLORS.white,
              borderRadius: 14, padding: "16px 20px",
              border: `1.5px solid ${selected?.id === emp.id ? COLORS.brand : COLORS.border}`,
              cursor: "pointer", display: "flex", alignItems: "center", gap: 16,
            }}>
              <div style={{ width: 44, height: 44, borderRadius: 13, background: COLORS.brand + "18", display: "flex", alignItems: "center", justifyContent: "center", fontSize: 15, fontWeight: 700, color: COLORS.brand, flexShrink: 0 }}>
                {emp.name.split(" ").map(n => n[0]).join("")}
              </div>
              <div style={{ flex: 1 }}>
                <div style={{ fontSize: 14, fontWeight: 700, color: COLORS.dark }}>{emp.name}</div>
                <div style={{ fontSize: 12, color: COLORS.muted }}>{emp.role} · {emp.dept}</div>
              </div>
              <div style={{ display: "flex", gap: 6, flexWrap: "wrap", justifyContent: "flex-end" }}>
                {emp.docs.map(d => <Badge key={d}>{d}</Badge>)}
              </div>
              <div style={{ width: 8, height: 8, borderRadius: 100, background: emp.status === "active" ? COLORS.success : COLORS.muted, flexShrink: 0 }} />
            </div>
          ))}
        </div>
      </div>

      {selected ? (
        <div style={{ background: COLORS.white, borderRadius: 16, border: `1px solid ${COLORS.border}`, padding: 24, alignSelf: "start" }}>
          <div style={{ display: "flex", justifyContent: "space-between", alignItems: "start", marginBottom: 20 }}>
            <div style={{ width: 56, height: 56, borderRadius: 16, background: COLORS.brand + "18", display: "flex", alignItems: "center", justifyContent: "center", fontSize: 20, fontWeight: 700, color: COLORS.brand }}>
              {selected.name.split(" ").map(n => n[0]).join("")}
            </div>
            <div style={{ display: "flex", gap: 8 }}>
              <button style={{ background: COLORS.bg, border: "none", borderRadius: 8, padding: "8px 14px", fontSize: 12, fontWeight: 600, color: COLORS.muted, cursor: "pointer" }}>Редагувати</button>
              <button style={{ background: "#fef2f2", border: "none", borderRadius: 8, padding: "8px 14px", fontSize: 12, fontWeight: 600, color: COLORS.danger, cursor: "pointer" }}>Заблокувати</button>
            </div>
          </div>
          <div style={{ fontSize: 18, fontWeight: 800, color: COLORS.dark, fontFamily: "Georgia, serif" }}>{selected.name}</div>
          <div style={{ fontSize: 13, color: COLORS.muted, marginTop: 2 }}>{selected.role} · {selected.dept}</div>
          <div style={{ height: 1, background: COLORS.border, margin: "20px 0" }} />
          <div style={{ fontSize: 12, fontWeight: 700, color: COLORS.muted, marginBottom: 12, textTransform: "uppercase", letterSpacing: 0.8 }}>Доступ до типів</div>
          {selected.docs.map(d => (
            <div key={d} style={{ display: "flex", alignItems: "center", justifyContent: "space-between", padding: "10px 0", borderBottom: `1px solid ${COLORS.bg}` }}>
              <span style={{ fontSize: 13, fontWeight: 600, color: COLORS.dark }}>{d}</span>
              <div style={{ display: "flex", alignItems: "center", gap: 8 }}>
                <span style={{ fontSize: 11, color: COLORS.success, fontWeight: 600 }}>● Активно</span>
                <button style={{ background: "none", border: "none", cursor: "pointer", color: COLORS.muted, fontSize: 16 }}>×</button>
              </div>
            </div>
          ))}
          <button style={{ marginTop: 16, background: COLORS.bg, border: `1.5px dashed ${COLORS.border}`, borderRadius: 10, padding: "10px", width: "100%", fontSize: 12, fontWeight: 700, color: COLORS.muted, cursor: "pointer" }}>
            + Додати тип документа
          </button>
          <div style={{ height: 1, background: COLORS.border, margin: "20px 0" }} />
          <div style={{ display: "flex", justifyContent: "space-between" }}>
            <div>
              <div style={{ fontSize: 11, color: COLORS.muted }}>Статус</div>
              <div style={{ fontSize: 13, fontWeight: 700, color: selected.status === "active" ? COLORS.success : COLORS.muted }}>{selected.status === "active" ? "Активний" : "Неактивний"}</div>
            </div>
            <div>
              <div style={{ fontSize: 11, color: COLORS.muted }}>Документів (місяць)</div>
              <div style={{ fontSize: 13, fontWeight: 700, color: COLORS.dark }}>43</div>
            </div>
          </div>
        </div>
      ) : (
        <div style={{ background: COLORS.white, borderRadius: 16, border: `1.5px dashed ${COLORS.border}`, padding: 40, display: "flex", flexDirection: "column", alignItems: "center", justifyContent: "center", gap: 12, color: COLORS.muted }}>
          <div style={{ fontSize: 32 }}>👤</div>
          <div style={{ fontSize: 13, fontWeight: 600 }}>Оберіть співробітника</div>
          <div style={{ fontSize: 12, textAlign: "center" }}>для перегляду деталей та налаштування доступів</div>
        </div>
      )}
    </div>
  );
}

// DOC TYPES
function DocTypes() {
  const [activeDoc, setActiveDoc] = useState(null);
  return (
    <div>
      <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", marginBottom: 24 }}>
        <div>
          <div style={{ fontSize: 20, fontWeight: 800, color: COLORS.dark, fontFamily: "Georgia, serif" }}>Типи документів</div>
          <div style={{ fontSize: 12, color: COLORS.muted }}>Налаштування категорій та маршрутизації</div>
        </div>
        <button style={{ background: COLORS.brand, color: "#fff", border: "none", borderRadius: 10, padding: "10px 18px", fontSize: 13, fontWeight: 700, cursor: "pointer" }}>+ Новий тип</button>
      </div>
      <div style={{ display: "grid", gridTemplateColumns: "repeat(3, 1fr)", gap: 16 }}>
        {docTypes.map(doc => (
          <div key={doc.id} onClick={() => setActiveDoc(activeDoc?.id === doc.id ? null : doc)} style={{
            background: COLORS.white, borderRadius: 16, padding: 24,
            border: `2px solid ${activeDoc?.id === doc.id ? doc.color : COLORS.border}`,
            cursor: "pointer", transition: "all 0.2s",
            boxShadow: activeDoc?.id === doc.id ? `0 8px 30px ${doc.color}25` : "none",
          }}>
            <div style={{ display: "flex", justifyContent: "space-between", alignItems: "start", marginBottom: 16 }}>
              <div style={{ width: 48, height: 48, borderRadius: 14, background: doc.color + "18", display: "flex", alignItems: "center", justifyContent: "center", fontSize: 22 }}>{doc.icon}</div>
              <Badge color={doc.color}>{doc.integration}</Badge>
            </div>
            <div style={{ fontSize: 16, fontWeight: 800, color: COLORS.dark }}>{doc.name}</div>
            <div style={{ display: "flex", gap: 16, marginTop: 16 }}>
              <div><div style={{ fontSize: 18, fontWeight: 800, color: doc.color }}>{doc.fields}</div><div style={{ fontSize: 11, color: COLORS.muted }}>полів</div></div>
              <div><div style={{ fontSize: 18, fontWeight: 800, color: COLORS.dark }}>{doc.workers}</div><div style={{ fontSize: 11, color: COLORS.muted }}>працівників</div></div>
            </div>
            {activeDoc?.id === doc.id && (
              <div style={{ marginTop: 16, paddingTop: 16, borderTop: `1px solid ${COLORS.border}` }}>
                <div style={{ display: "flex", gap: 8 }}>
                  <button style={{ flex: 1, background: doc.color, color: "#fff", border: "none", borderRadius: 8, padding: "8px", fontSize: 12, fontWeight: 700, cursor: "pointer" }}>Редагувати</button>
                  <button style={{ flex: 1, background: COLORS.bg, color: COLORS.muted, border: "none", borderRadius: 8, padding: "8px", fontSize: 12, fontWeight: 600, cursor: "pointer" }}>Шаблон</button>
                </div>
              </div>
            )}
          </div>
        ))}
        <div style={{ borderRadius: 16, border: `2px dashed ${COLORS.border}`, display: "flex", alignItems: "center", justifyContent: "center", flexDirection: "column", gap: 10, padding: 40, cursor: "pointer", color: COLORS.muted, minHeight: 180 }}>
          <div style={{ fontSize: 28, opacity: 0.5 }}>+</div>
          <div style={{ fontSize: 13, fontWeight: 600 }}>Додати тип</div>
        </div>
      </div>
    </div>
  );
}

// TEMPLATES
function Templates() {
  const [active, setActive] = useState(0);
  const t = templates[active];
  return (
    <div>
      <div style={{ marginBottom: 24 }}>
        <div style={{ fontSize: 20, fontWeight: 800, color: COLORS.dark, fontFamily: "Georgia, serif" }}>Шаблони розпаршування</div>
        <div style={{ fontSize: 12, color: COLORS.muted }}>Налаштування полів екстракції для кожного типу</div>
      </div>
      <div style={{ display: "grid", gridTemplateColumns: "220px 1fr", gap: 20 }}>
        <div style={{ display: "flex", flexDirection: "column", gap: 8 }}>
          {templates.map((tp, i) => (
            <div key={tp.id} onClick={() => setActive(i)} style={{
              background: active === i ? COLORS.brand : COLORS.white,
              borderRadius: 12, padding: "14px 16px",
              border: `1.5px solid ${active === i ? COLORS.brand : COLORS.border}`,
              cursor: "pointer",
            }}>
              <div style={{ fontSize: 13, fontWeight: 700, color: active === i ? "#fff" : COLORS.dark }}>{tp.docType}</div>
              <div style={{ fontSize: 11, color: active === i ? "rgba(255,255,255,0.7)" : COLORS.muted, marginTop: 2 }}>{tp.fields.length} полів</div>
            </div>
          ))}
          <div style={{ borderRadius: 12, border: `1.5px dashed ${COLORS.border}`, padding: "14px 16px", cursor: "pointer", textAlign: "center", color: COLORS.muted, fontSize: 12, fontWeight: 600 }}>
            + Новий шаблон
          </div>
        </div>

        <div style={{ background: COLORS.white, borderRadius: 16, border: `1px solid ${COLORS.border}`, padding: 28 }}>
          <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", marginBottom: 24 }}>
            <div style={{ fontSize: 17, fontWeight: 800, color: COLORS.dark, fontFamily: "Georgia, serif" }}>{t.docType}</div>
            <button style={{ background: COLORS.brand, color: "#fff", border: "none", borderRadius: 8, padding: "8px 16px", fontSize: 12, fontWeight: 700, cursor: "pointer" }}>Зберегти</button>
          </div>
          <div style={{ fontSize: 12, fontWeight: 700, color: COLORS.muted, textTransform: "uppercase", letterSpacing: 0.8, marginBottom: 14 }}>Поля для екстракції</div>
          <div style={{ display: "flex", flexDirection: "column", gap: 10 }}>
            {t.fields.map((field, i) => (
              <div key={i} style={{ display: "flex", alignItems: "center", gap: 12, padding: "12px 16px", background: COLORS.bg, borderRadius: 10 }}>
                <div style={{ width: 24, height: 24, borderRadius: 6, background: COLORS.brand + "20", display: "flex", alignItems: "center", justifyContent: "center" }}>
                  <svg width="12" height="12" fill="none" viewBox="0 0 24 24"><path d="M8 6h13M8 12h13M8 18h13M3 6h.01M3 12h.01M3 18h.01" stroke={COLORS.brand} strokeWidth="2" strokeLinecap="round"/></svg>
                </div>
                <span style={{ fontSize: 13, fontWeight: 600, color: COLORS.dark, flex: 1 }}>{field}</span>
                <select style={{ border: "none", background: "transparent", color: COLORS.muted, fontSize: 12, cursor: "pointer" }}>
                  <option>Текст</option><option>Число</option><option>Дата</option><option>Таблиця</option>
                </select>
                <button style={{ background: "none", border: "none", color: COLORS.muted, cursor: "pointer", fontSize: 16 }}>×</button>
              </div>
            ))}
            <button style={{ background: COLORS.bg, border: `1.5px dashed ${COLORS.border}`, borderRadius: 10, padding: "12px", fontSize: 12, fontWeight: 700, color: COLORS.muted, cursor: "pointer" }}>
              + Додати поле
            </button>
          </div>
        </div>
      </div>
    </div>
  );
}

// INTEGRATIONS
function Integrations() {
  const integList = [
    { name: "1С/БАС Бухгалтерія", status: "connected", types: ["Накладні", "Рахунки-фактури"], icon: "🏢", color: "#f59e0b" },
    { name: "MedCRM", status: "connected", types: ["Медичні довідки"], icon: "🏥", color: "#10b981" },
    { name: "DocFlow", status: "pending", types: ["Договори"], icon: "📋", color: "#8b5cf6" },
    { name: "HR Portal", status: "disconnected", types: ["Паспорти"], icon: "👥", color: "#ef4444" },
  ];
  return (
    <div>
      <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", marginBottom: 24 }}>
        <div>
          <div style={{ fontSize: 20, fontWeight: 800, color: COLORS.dark, fontFamily: "Georgia, serif" }}>Інтеграції</div>
          <div style={{ fontSize: 12, color: COLORS.muted }}>Підключення зовнішніх систем та Webhook-маршрутизація</div>
        </div>
        <button style={{ background: COLORS.brand, color: "#fff", border: "none", borderRadius: 10, padding: "10px 18px", fontSize: 13, fontWeight: 700, cursor: "pointer" }}>+ Нова інтеграція</button>
      </div>
      <div style={{ display: "flex", flexDirection: "column", gap: 14 }}>
        {integList.map((integ, i) => (
          <div key={i} style={{ background: COLORS.white, borderRadius: 16, border: `1px solid ${COLORS.border}`, padding: "20px 24px", display: "flex", alignItems: "center", gap: 20 }}>
            <div style={{ width: 52, height: 52, borderRadius: 14, background: integ.color + "18", display: "flex", alignItems: "center", justifyContent: "center", fontSize: 22, flexShrink: 0 }}>{integ.icon}</div>
            <div style={{ flex: 1 }}>
              <div style={{ display: "flex", alignItems: "center", gap: 10, marginBottom: 4 }}>
                <div style={{ fontSize: 15, fontWeight: 800, color: COLORS.dark }}>{integ.name}</div>
                <span style={{
                  background: integ.status === "connected" ? COLORS.success + "18" : integ.status === "pending" ? COLORS.warning + "18" : "#ef444418",
                  color: integ.status === "connected" ? COLORS.success : integ.status === "pending" ? COLORS.warning : COLORS.danger,
                  fontSize: 11, fontWeight: 700, padding: "3px 10px", borderRadius: 100,
                }}>
                  {integ.status === "connected" ? "● Підключено" : integ.status === "pending" ? "◌ Очікує" : "○ Відключено"}
                </span>
              </div>
              <div style={{ display: "flex", gap: 6 }}>{integ.types.map(t => <Badge key={t}>{t}</Badge>)}</div>
            </div>
            <div style={{ textAlign: "right" }}>
              <div style={{ fontSize: 11, color: COLORS.muted, marginBottom: 4 }}>Webhook URL</div>
              <div style={{ fontSize: 11, fontFamily: "monospace", color: COLORS.brand, background: COLORS.brand + "10", padding: "4px 10px", borderRadius: 6 }}>api.rekognita.io/wh/...</div>
            </div>
            <button style={{ background: COLORS.bg, border: "none", borderRadius: 10, padding: "10px 16px", fontSize: 12, fontWeight: 600, color: COLORS.muted, cursor: "pointer", marginLeft: 8 }}>Налаштувати</button>
          </div>
        ))}
      </div>
      <div style={{ marginTop: 24, background: COLORS.white, borderRadius: 16, border: `1px solid ${COLORS.border}`, padding: 24 }}>
        <div style={{ fontSize: 14, fontWeight: 700, color: COLORS.dark, marginBottom: 4 }}>🔒 Безпека передачі даних</div>
        <div style={{ fontSize: 12, color: COLORS.muted, lineHeight: 1.7 }}>
          Всі дані передаються по зашифрованому каналу (TLS 1.3). Фотографії документів не зберігаються після обробки. Self-Hosted контур повністю ізольований від публічних LLM. Кожен Webhook підписується HMAC-SHA256.
        </div>
      </div>
    </div>
  );
}

// APP ROOT
export default function RekognitaManager() {
  const [loggedIn, setLoggedIn] = useState(false);
  const [activeNav, setActiveNav] = useState("dashboard");
  const [currentCompany, setCurrentCompany] = useState(companies[0]);

  if (!loggedIn) return <LoginPage onLogin={() => setLoggedIn(true)} />;

  const screens = {
    dashboard: () => <Dashboard company={currentCompany} />,
    team: Team,
    doctypes: DocTypes,
    templates: Templates,
    integrations: Integrations,
  };
  const ActiveScreen = screens[activeNav];

  return (
    <div style={{ fontFamily: "'DM Sans', 'Segoe UI', sans-serif", background: COLORS.bg, minHeight: "100vh", display: "flex" }}>
      <div style={{ width: 224, background: COLORS.dark, minHeight: "100vh", display: "flex", flexDirection: "column", padding: "24px 14px", flexShrink: 0 }}>
        <div style={{ marginBottom: 24, paddingLeft: 6 }}>
          <div style={{ display: "flex", alignItems: "center", gap: 8 }}>
            <div style={{ width: 32, height: 32, borderRadius: 9, background: COLORS.brand, display: "flex", alignItems: "center", justifyContent: "center" }}>
              <svg width="18" height="18" fill="none" viewBox="0 0 24 24"><path d="M9 3H5a2 2 0 00-2 2v4m6-6h10a2 2 0 012 2v4M9 3v18m0 0h10a2 2 0 002-2v-4M9 21H5a2 2 0 01-2-2v-4m0 0h18" stroke="#fff" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/></svg>
            </div>
            <div>
              <div style={{ fontSize: 13, fontWeight: 800, color: "#fff", letterSpacing: -0.3 }}>Re::kognita</div>
              <div style={{ fontSize: 10, color: "rgba(255,255,255,0.35)", letterSpacing: 0.5 }}>MANAGER</div>
            </div>
          </div>
        </div>

        <CompanySwitcher currentCompany={currentCompany} onSwitch={setCurrentCompany} />

        <nav style={{ display: "flex", flexDirection: "column", gap: 3, flex: 1 }}>
          {navItems.map(item => {
            const active = activeNav === item.id;
            const Icon = item.icon;
            return (
              <button key={item.id} onClick={() => setActiveNav(item.id)} style={{
                background: active ? COLORS.brand : "transparent",
                border: "none", borderRadius: 10, padding: "11px 12px",
                display: "flex", alignItems: "center", gap: 10,
                cursor: "pointer", textAlign: "left",
                boxShadow: active ? `0 4px 14px ${COLORS.brand}50` : "none",
              }}>
                <Icon active={active} />
                <span style={{ fontSize: 13, fontWeight: active ? 700 : 500, color: active ? "#fff" : "rgba(255,255,255,0.45)" }}>
                  {item.label}
                </span>
              </button>
            );
          })}
        </nav>

        <div style={{ borderTop: "1px solid rgba(255,255,255,0.08)", paddingTop: 14, display: "flex", alignItems: "center", gap: 10 }}>
          <div style={{ width: 36, height: 36, borderRadius: 10, background: COLORS.brand, display: "flex", alignItems: "center", justifyContent: "center", fontSize: 13, fontWeight: 700, color: "#fff", flexShrink: 0 }}>АК</div>
          <div style={{ flex: 1, minWidth: 0 }}>
            <div style={{ fontSize: 12, fontWeight: 700, color: "#fff" }}>Андрій Ковач</div>
            <div style={{ fontSize: 11, color: "rgba(255,255,255,0.35)" }}>Власник</div>
          </div>
          <button onClick={() => setLoggedIn(false)} title="Вийти" style={{ background: "none", border: "none", cursor: "pointer", color: "rgba(255,255,255,0.3)", padding: 4 }}>
            <svg width="16" height="16" fill="none" viewBox="0 0 24 24"><path d="M9 21H5a2 2 0 01-2-2V5a2 2 0 012-2h4M16 17l5-5-5-5M21 12H9" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/></svg>
          </button>
        </div>
      </div>

      <div style={{ flex: 1, padding: "32px 36px", overflow: "auto" }}>
        <ActiveScreen />
      </div>
    </div>
  );
}
