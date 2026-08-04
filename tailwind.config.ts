import type { Config } from "tailwindcss";

const config: Config = {
  content: [
    "./src/pages/**/*.{js,ts,jsx,tsx,mdx}",
    "./src/components/**/*.{js,ts,jsx,tsx,mdx}",
    "./src/app/**/*.{js,ts,jsx,tsx,mdx}",
  ],
  theme: {
    extend: {
      fontFamily: {
        heading: ["var(--font-plus-jakarta-sans)", "system-ui", "sans-serif"],
        body: ["var(--font-inter)", "system-ui", "sans-serif"],
        mono: ["var(--font-jetbrains-mono)", "monospace"],
      },
      colors: {
        grafite: "#1F2937",
        "grafite-light": "#2D3A48",
        "grafite-dark": "#111827",
        petroleo: "#3E5653",
        "petroleo-light": "#4A6B67",
        "cinza-verde": "#627271",
        menta: "#86CB92",
        "menta-light": "#A3DBAE",
        "menta-dark": "#6BB87A",
        "cinza-claro": "#EFEFEF",
        branco: "#FFFFFF",
        danger: "#E57373",
        warning: "#F0C75E",
        surface: "#F5F5F5",
        background: "#EFEFEF",
        foreground: "#1F2937",
      },
      borderRadius: {
        sm: "4px",
        md: "8px",
        lg: "12px",
        xl: "16px",
        "2xl": "24px",
        full: "999px",
      },
      boxShadow: {
        card: "0 1px 3px rgba(0,0,0,0.06), 0 1px 2px rgba(0,0,0,0.04)",
        elevated: "0 4px 6px rgba(0,0,0,0.07), 0 2px 4px rgba(0,0,0,0.04)",
        modal: "0 10px 25px rgba(0,0,0,0.12), 0 4px 10px rgba(0,0,0,0.06)",
        toast: "0 20px 40px rgba(0,0,0,0.15)",
      },
    },
  },
  plugins: [],
};
export default config;
