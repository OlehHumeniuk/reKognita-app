import { useState, useEffect } from "react";

function useCountUp(target, duration, delay) {
  const [val, setVal] = useState(0);
  useEffect(() => {
    const t = setTimeout(() => {
      let start = 0;
      const steps = 50;
      const inc = target / steps;
      const iv = setInterval(() => {
        start += inc;
        if (start >= target) { setVal(target); clearInterval(iv); }
        else setVal(Math.floor(start));
      }, (duration || 900) / steps);
      return () => clearInterval(iv);
    }, delay || 0);
    return () => clearTimeout(t);
  }, [target]);
  return val;
}

function Sparkline({ data, color }) {
  const max = Math.max(...data), min = Math.min(...data);
  const range = max - min || 1;
  const w = 120, h = 32;
  const pts = data.map((v, i) => [
    (i / (data.length - 1)) * w,
    h - ((v - min) / range) * (h - 6) - 3,
  ]);
  const line = pts.map((p, i) => (i === 0 ? "M" : "L") + p[0].toFixed(2) + "," + p[1].toFixed(2)).join(" ");
  const area = line + " L" + w + "," + h + " L0," + h + " Z";
  return (
    <svg width={w} height={h} viewBox={"0 0 " + w + " " + h} style={{ overflow: "visible" }}>
      <defs>
        <linearGradient id="sg" x1="0" y1="0" x2="0" y2="1">
          <stop offset="0%" stopColor={color} stopOpacity="0.22"/>
          <stop offset="100%" stopColor={color} stopOpacity="0"/>
        </linearGradient>
      </defs>
      <path d={area} fill="url(#sg)"/>
      <path d={line} fill="none" stroke={color} strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/>
      <circle cx={pts[pts.length-1][0]} cy={pts[pts.length-1][1]} r="3.5" fill="#fff" strokeWidth="2" stroke={color}/>
    </svg>
  );
}

export default function DocCard() {
  const count = useCountUp(247, 1000, 200);
  const accent = "#2563eb";

  return (
    <div style={{
      minHeight: "100vh",
      background: "#f1f5f9",
      display: "flex",
      alignItems: "center",
      justifyContent: "center",
      padding: 24,
      fontFamily: "'DM Sans', 'Segoe UI', sans-serif",
    }}>
      <div style={{ width: 335 }}>

        <div style={{
          background: "#fff",
          borderRadius: 24,
          padding: "24px 24px 0",
          border: "1px solid #e2eaf4",
          boxShadow: "0 4px 28px rgba(37,99,235,0.08), 0 1px 4px rgba(15,23,42,0.04)",
          overflow: "hidden",
          position: "relative",
        }}>

          <div style={{
            position: "absolute", top: -40, right: -40,
            width: 160, height: 160, borderRadius: "50%",
            background: "radial-gradient(circle, rgba(37,99,235,0.07) 0%, transparent 70%)",
            pointerEvents: "none",
          }}/>

          {/* ROW 1 — відступ 24px */}
          <div style={{
            display: "flex", alignItems: "center", justifyContent: "center",
            gap: 12, marginBottom: 24,
          }}>
            <div style={{
              width: 40, height: 40, borderRadius: 12,
              background: accent + "12",
              display: "flex", alignItems: "center", justifyContent: "center",
              flexShrink: 0,
            }}>
              <svg width="20" height="20" fill="none" viewBox="0 0 24 24">
                <path d="M14 2H6a2 2 0 00-2 2v16a2 2 0 002 2h12a2 2 0 002-2V8l-6-6z" stroke={accent} strokeWidth="1.6" strokeLinejoin="round"/>
                <path d="M14 2v6h6" stroke={accent} strokeWidth="1.6" strokeLinejoin="round"/>
                <path d="M8 13h8M8 17h5" stroke={accent} strokeWidth="1.6" strokeLinecap="round"/>
              </svg>
            </div>
            <span style={{ fontSize: 20, fontWeight: 700, color: "#0f172a", letterSpacing: -0.4, lineHeight: 1.2 }}>
              Документів сьогодні
            </span>
          </div>

          {/* ROW 2 — відступ 24px */}
          <div style={{
            fontSize: 72, fontWeight: 900, color: "#0f172a",
            fontFamily: "Georgia, serif", letterSpacing: -4,
            lineHeight: 1, marginBottom: 24, textAlign: "center",
          }}>
            {count}
          </div>

          {/* ROW 3 — delta strip */}
          <div style={{
            margin: "0 -24px",
            padding: "12px 24px",
            background: "linear-gradient(90deg, rgba(16,185,129,0.08) 0%, rgba(16,185,129,0.04) 100%)",
            borderTop: "1px solid rgba(16,185,129,0.15)",
            display: "flex", alignItems: "center", justifyContent: "space-between",
          }}>
            <div style={{ display: "flex", alignItems: "center", gap: 10 }}>
              <div style={{
                width: 36, height: 36, borderRadius: 10,
                background: "rgba(16,185,129,0.15)",
                display: "flex", alignItems: "center", justifyContent: "center",
              }}>
                <svg width="20" height="20" fill="none" viewBox="0 0 24 24">
                  <path d="M7 17L17 7M17 7H7M17 7v10" stroke="#059669" strokeWidth="2.4" strokeLinecap="round" strokeLinejoin="round"/>
                </svg>
              </div>
              <div style={{ fontSize: 15, fontWeight: 800, color: "#059669", letterSpacing: -0.3 }}>
                +18% до вчора
              </div>
            </div>
            <Sparkline data={[38,52,44,68,60,78,72,88,82,98,90,108]} color="#059669" />
          </div>

        </div>

        <div style={{ marginTop: 12, display: "flex", alignItems: "center", gap: 6, paddingLeft: 4 }}>
          <div style={{ width: 6, height: 6, borderRadius: "50%", background: "#10b981" }}/>
          <span style={{ fontSize: 11, color: "#94a3b8", fontWeight: 500 }}>Оновлено щойно</span>
        </div>

      </div>
    </div>
  );
}
