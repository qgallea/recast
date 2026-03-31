"""
RECAST Pipeline — Visual Architecture Diagram (matplotlib)
"""
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
from matplotlib.patches import FancyBboxPatch, FancyArrowPatch
import numpy as np

# ── Canvas ──
fig, ax = plt.subplots(figsize=(28, 38))
ax.set_xlim(-1, 27)
ax.set_ylim(-1, 53)
ax.set_aspect("equal")
ax.axis("off")
fig.patch.set_facecolor("#FAFBFD")

# ── Palette ──
C_CMD    = "#2563EB"   # blue — commands
C_ORCH   = "#334155"   # dark slate — orchestrator
C_STAGE  = "#059669"   # green — stages
C_S4VAR  = "#10B981"   # lighter green — stage 4 variants
C_GATE   = "#EA580C"   # orange — gate
C_CHECK  = "#F97316"   # light orange — checks
C_REF    = "#DB2777"   # pink — referees
C_SYNTH  = "#7C3AED"   # purple — synthesis
C_REV    = "#DC2626"   # red — revision
C_FINAL  = "#0891B2"   # cyan — final
C_DECIDE = "#F59E0B"   # amber — decisions
C_FILE   = "#E2E8F0"   # light grey — files
C_STOP   = "#991B1B"   # dark red
C_BG_GREEN  = "#ECFDF5"
C_BG_ORANGE = "#FFF7ED"
C_BG_PURPLE = "#FAF5FF"
C_BG_BLUE   = "#EFF6FF"

def draw_box(x, y, w, h, color, label, sublabel="", sublabel2="", alpha=1.0, fontsize=11, text_color="white", border_color=None):
    """Draw a rounded rectangle with centered text."""
    bc = border_color or color
    box = FancyBboxPatch((x, y), w, h, boxstyle="round,pad=0.15",
                          facecolor=color, edgecolor=bc, linewidth=1.8, alpha=alpha)
    ax.add_patch(box)
    cy = y + h/2
    if sublabel2:
        ax.text(x + w/2, cy + 0.35, label, ha="center", va="center",
                fontsize=fontsize, fontweight="bold", color=text_color, family="sans-serif")
        ax.text(x + w/2, cy - 0.15, sublabel, ha="center", va="center",
                fontsize=8, color=text_color, alpha=0.9, family="sans-serif")
        ax.text(x + w/2, cy - 0.55, sublabel2, ha="center", va="center",
                fontsize=7, color=text_color, alpha=0.7, family="sans-serif", style="italic")
    elif sublabel:
        ax.text(x + w/2, cy + 0.2, label, ha="center", va="center",
                fontsize=fontsize, fontweight="bold", color=text_color, family="sans-serif")
        ax.text(x + w/2, cy - 0.25, sublabel, ha="center", va="center",
                fontsize=8, color=text_color, alpha=0.9, family="sans-serif")
    else:
        ax.text(x + w/2, cy, label, ha="center", va="center",
                fontsize=fontsize, fontweight="bold", color=text_color, family="sans-serif")
    return (x + w/2, y, x + w/2, y + h)  # bottom_center, top_center

def draw_diamond(cx, cy, size, color, label, fontsize=9):
    """Draw a diamond decision node."""
    d = size
    diamond = plt.Polygon([(cx, cy+d), (cx+d, cy), (cx, cy-d), (cx-d, cy)],
                           facecolor=color, edgecolor="#333", linewidth=1.5)
    ax.add_patch(diamond)
    lines = label.split("\n")
    for i, line in enumerate(lines):
        offset = (len(lines)-1) * 0.15 - i * 0.3
        ax.text(cx, cy + offset, line, ha="center", va="center",
                fontsize=fontsize, fontweight="bold", color="#1a1a2e", family="sans-serif")

def arrow(x1, y1, x2, y2, color="#666", lw=1.5, style="-", label="", label_side="right"):
    """Draw an arrow between two points."""
    if style == "dashed":
        ax.annotate("", xy=(x2, y2), xytext=(x1, y1),
                     arrowprops=dict(arrowstyle="-|>", color=color, lw=lw,
                                     linestyle="dashed", shrinkA=3, shrinkB=3))
    else:
        ax.annotate("", xy=(x2, y2), xytext=(x1, y1),
                     arrowprops=dict(arrowstyle="-|>", color=color, lw=lw,
                                     shrinkA=3, shrinkB=3))
    if label:
        mx, my = (x1+x2)/2, (y1+y2)/2
        offset = 0.3 if label_side == "right" else -0.3
        ax.text(mx + offset, my, label, fontsize=7, color="#555",
                ha="left" if label_side == "right" else "right",
                va="center", family="sans-serif", style="italic")

def draw_bg_region(x, y, w, h, color, label="", fontsize=10):
    """Draw a background region."""
    rect = FancyBboxPatch((x, y), w, h, boxstyle="round,pad=0.3",
                           facecolor=color, edgecolor="#CCC", linewidth=1, linestyle="--", alpha=0.6)
    ax.add_patch(rect)
    if label:
        ax.text(x + 0.4, y + h - 0.3, label, fontsize=fontsize, fontweight="bold",
                color="#444", family="sans-serif", va="top")

# ═══════════════════════════════════════════════════════
# TITLE
# ═══════════════════════════════════════════════════════
ax.text(13, 52.2, "RECAST Pipeline Architecture", ha="center", va="center",
        fontsize=28, fontweight="bold", color="#1a1a2e", family="sans-serif")
ax.text(13, 51.5, "Replication and Extension with Causal AI Statistical Toolkit",
        ha="center", va="center", fontsize=13, color="#666", family="sans-serif")

# ═══════════════════════════════════════════════════════
# ENTRY POINTS
# ═══════════════════════════════════════════════════════
draw_bg_region(0.5, 49, 25, 2, C_BG_BLUE, "Entry Points (slash commands)")

cmds = [("/run", "/recast"), ("/recast-cf",), ("/init",), ("/stage N",), ("/review",), ("/final",), ("/publish",)]
cmd_labels = ["/run & /recast", "/recast-cf", "/init", "/stage N", "/review", "/final", "/publish"]
cmd_xs = [1.2, 5, 8.5, 11.8, 15.2, 18.5, 21.8]

for i, (cx, lbl) in enumerate(zip(cmd_xs, cmd_labels)):
    draw_box(cx, 49.3, 2.8, 1.0, C_CMD, lbl, fontsize=9)

# ═══════════════════════════════════════════════════════
# ORCHESTRATOR
# ═══════════════════════════════════════════════════════
draw_box(8.5, 47, 9, 1.5, C_ORCH, "ORCHESTRATOR",
         "State manager & dispatcher  |  Reads config.yaml + orchestrator.md",
         fontsize=13, text_color="white")

# arrows from commands to orchestrator
arrow(2.6, 49.3, 11, 48.5, C_CMD, 1.5)
arrow(6.4, 49.3, 11.5, 48.5, C_CMD, 1.2)
arrow(13.2, 49.3, 13, 48.5, C_CMD, 1.2)

# ═══════════════════════════════════════════════════════
# NOTEBOOK STAGES
# ═══════════════════════════════════════════════════════
draw_bg_region(1, 31.5, 24, 15, C_BG_GREEN, "Notebook Stages (sequential execution via notebook_runner)")

# Stage 1
draw_box(9.5, 44, 7, 1.8, C_STAGE, "Stage 1: Paper Intelligence",
         "01_paper_intelligence.ipynb", "PDF → paper_spec.json (read-only)")
arrow(13, 47, 13, 45.8, C_STAGE, 2)

# Stage 2
draw_box(9.5, 41.2, 7, 1.8, C_STAGE, "Stage 2: Data Preparation",
         "02_data.ipynb", "raw_data → dataset.parquet")
arrow(13, 44, 13, 43, C_STAGE, 2, label="paper_spec.json")

# Stage 3
draw_box(9.5, 38.4, 7, 1.8, C_STAGE, "Stage 3: Replication",
         "03_replication.ipynb", "OLS/IV2SLS → replication_*.json")
arrow(13, 41.2, 13, 40.2, C_STAGE, 2, label="dataset.parquet")

# Decision diamond — pipeline variant
draw_diamond(13, 36.6, 0.8, C_DECIDE, "Pipeline\nvariant?")
arrow(13, 38.4, 13, 37.4, C_STAGE, 2, label="replication_*.json")

# Stage 4 DML
draw_box(3, 33.8, 8, 1.8, C_S4VAR, "Stage 4: DoubleML Extension",
         "04_dml_extension.ipynb", "PLIR/PLIV/IRM + optional Causal Forest")
arrow(12.2, 36.6, 7, 35.6, C_S4VAR, 1.8, label="/recast", label_side="left")

# Stage 4cf
draw_box(15, 33.8, 8, 1.8, C_S4VAR, "Stage 4cf: Causal Forest",
         "04_causal_forest.ipynb", "CausalForestDML / CausalIVForest")
arrow(13.8, 36.6, 19, 35.6, C_S4VAR, 1.8, label="/recast-cf")

# Merge point
ax.plot(13, 32.8, "o", color="#333", markersize=8, zorder=5)
arrow(7, 33.8, 13, 33, "#666", 1.5)
arrow(19, 33.8, 13, 33, "#666", 1.5)

# Stage 5
draw_box(9.5, 32, 7, 1.0, C_STAGE, "Stage 5: Diagnostics",
         "9 automated checks → diagnostics_flags.json", fontsize=10)
arrow(13, 32.8, 13, 33, C_STAGE, 1.5)

# Stage 6
draw_box(9.5, 31.5, 7, 0, C_STAGE, "", fontsize=0)  # invisible spacer
# Actually let me position stage 6 properly
# Remove the invisible spacer and draw stage 6
draw_box(9.5, 30.2, 7, 1.2, C_STAGE, "Stage 6: Report Generation",
         "paper.tex + paper.pdf", fontsize=10)
arrow(13, 32, 13, 31.4, C_STAGE, 1.5)

# ═══════════════════════════════════════════════════════
# ADVISOR GATE
# ═══════════════════════════════════════════════════════
draw_bg_region(1, 25.5, 24, 4.2, C_BG_ORANGE, "Advisor Gate (all 3 must PASS)")

draw_box(2, 26.2, 6.5, 2.5, C_GATE, "Check 1", "Code Auditor",
         "Replication within tolerance?\nSample sizes match?", text_color="white")
draw_box(9.75, 26.2, 6.5, 2.5, C_GATE, "Check 2", "Identification",
         "Estimand defined?\nStrategy consistent?", text_color="white")
draw_box(17.5, 26.2, 6.5, 2.5, C_GATE, "Check 3", "Data Validator",
         "No critical flags?\nNo excess missingness?", text_color="white")

arrow(13, 30.2, 5.25, 28.7, C_GATE, 1.8)
arrow(13, 30.2, 13, 28.7, C_GATE, 1.8)
arrow(13, 30.2, 20.75, 28.7, C_GATE, 1.8)

# Gate decision
draw_diamond(13, 24.5, 0.7, C_DECIDE, "All 3\nPASS?", fontsize=8)
arrow(5.25, 26.2, 13, 25.2, C_GATE, 1.2)
arrow(13, 26.2, 13, 25.2, C_GATE, 1.2)
arrow(20.75, 26.2, 13, 25.2, C_GATE, 1.2)

# STOP node
draw_box(20, 23.5, 3.5, 1.2, C_STOP, "STOP", "Report failed check(s)", text_color="white")
arrow(13.7, 24.5, 20, 24.1, C_STOP, 1.8, label="FAIL")

# ═══════════════════════════════════════════════════════
# REVIEW LOOP
# ═══════════════════════════════════════════════════════
draw_bg_region(1, 10.5, 24, 13.2, C_BG_PURPLE, "Review Loop (up to 3 rounds)")

# Referees (isolated)
# Sub-region for referees
draw_bg_region(1.8, 18.8, 22.4, 4, "#FDF2F8", "Isolated Referees (no cross-communication)")

draw_box(2.5, 19.3, 6.5, 2.5, C_REF, "Referee 1", "Identification",
         "7-item checklist\nEstimand, strategy, IV, OVB", text_color="white")
draw_box(9.75, 19.3, 6.5, 2.5, C_REF, "Referee 2", "DML & CF Methods",
         "21-item checklist\nLearners, SEs, GATE, CATE", text_color="white")
draw_box(17.5, 19.3, 6.5, 2.5, C_REF, "Referee 3", "Robustness",
         "8-item checklist\nFidelity, forest plot, SEs", text_color="white")

ax.text(13, 23.2, "PASS", fontsize=10, fontweight="bold", color=C_STAGE,
        ha="center", va="center", family="sans-serif")
arrow(13, 23.8, 5.75, 21.8, "#4CAF50", 2)
arrow(13, 23.8, 13, 21.8, "#4CAF50", 2)
arrow(13, 23.8, 20.75, 21.8, "#4CAF50", 2)

# Synthesis
draw_box(7.5, 16.5, 11, 2, C_SYNTH, "Synthesis Referee",
         "First agent to see all 3 reports", "Deduplicates & ranks: blocking → major → minor",
         text_color="white")

arrow(5.75, 19.3, 10, 18.5, C_SYNTH, 1.5, label="ref1.md", label_side="left")
arrow(13, 19.3, 13, 18.5, C_SYNTH, 1.5, label="ref2.md")
arrow(20.75, 19.3, 16, 18.5, C_SYNTH, 1.5, label="ref3.md")

# Revision agent
draw_box(7.5, 13.5, 11, 2, C_REV, "Revision Agent",
         "Only agent that edits paper.tex & code_build/",
         "Blocking → edit notebooks | Major/Minor → edit LaTeX",
         text_color="white")

arrow(13, 16.5, 13, 15.5, C_SYNTH, 1.8, label="synthesis.md")

# Blocking decision
draw_diamond(13, 11.8, 0.7, C_DECIDE, "Blocking\nissues?", fontsize=8)
arrow(13, 13.5, 13, 12.5, C_REV, 1.5, label="changelog_N.md")

# Re-run arrow (back to stage 4)
ax.annotate("", xy=(0.5, 36.6), xytext=(0.5, 11.8),
            arrowprops=dict(arrowstyle="-|>", color=C_STOP, lw=2.5,
                            linestyle="dashed", connectionstyle="arc3,rad=0"))
ax.annotate("", xy=(3, 34.7), xytext=(0.5, 36.6),
            arrowprops=dict(arrowstyle="-|>", color=C_STOP, lw=2.5,
                            linestyle="dashed"))
arrow(12.3, 11.8, 0.5, 11.8, C_STOP, 2, style="dashed")
ax.text(0.0, 24, "YES → RERUN\n/stage 4\n(re-execute\nnotebooks 4–6)", fontsize=8,
        fontweight="bold", color=C_STOP, ha="center", va="center",
        family="sans-serif", rotation=90,
        bbox=dict(boxstyle="round,pad=0.3", facecolor="#FEE2E2", edgecolor=C_STOP, alpha=0.9))

# Max rounds decision
draw_diamond(19, 11.8, 0.7, C_DECIDE, "Max\nrounds?", fontsize=8)
ax.text(15.8, 12.1, "NO", fontsize=9, fontweight="bold", color=C_STAGE,
        ha="center", family="sans-serif")
arrow(13.7, 11.8, 18.3, 11.8, C_STAGE, 1.5)

# Loop back arrow to referees
ax.annotate("", xy=(24, 20.5), xytext=(24, 11.8),
            arrowprops=dict(arrowstyle="-|>", color=C_SYNTH, lw=2,
                            linestyle="dashed", connectionstyle="arc3,rad=0"))
arrow(19.7, 11.8, 24, 11.8, C_SYNTH, 1.5, style="dashed")
ax.annotate("", xy=(20.75, 19.3), xytext=(24, 20.5),
            arrowprops=dict(arrowstyle="-|>", color=C_SYNTH, lw=2,
                            linestyle="dashed"))
ax.text(25.2, 16, "< max →\nnext round", fontsize=8, color=C_SYNTH,
        ha="center", va="center", family="sans-serif", fontweight="bold",
        bbox=dict(boxstyle="round,pad=0.2", facecolor="#F3E5F5", edgecolor=C_SYNTH, alpha=0.8))

# ═══════════════════════════════════════════════════════
# FINAL REPORT & PUBLISH
# ═══════════════════════════════════════════════════════
draw_box(7, 8.5, 6, 1.5, C_FINAL, "Final Referee",
         "Reads entire review history", "→ final_report.md", text_color="white")
draw_box(15, 8.5, 6, 1.5, C_FINAL, "Publish",
         "Quarto page generation", "→ website/papers/<slug>/", text_color="white")

ax.text(19.7, 11.1, "done / max reached", fontsize=8, color="#333",
        ha="center", family="sans-serif")
arrow(19, 11.1, 10, 10, C_FINAL, 2)
arrow(13, 10, 18, 10, C_FINAL, 1.5, label="final_report.md")

# Direct command arrows
arrow(19.9, 49.3, 10, 10, C_CMD, 1, style="dashed")  # /final direct
ax.text(19.5, 48.7, "/final direct", fontsize=7, color=C_CMD, family="sans-serif", rotation=70)

arrow(22.2, 49.3, 18, 10, C_CMD, 1, style="dashed")  # /publish direct
# /review direct
arrow(16.6, 49.3, 16, 21.8, C_CMD, 1, style="dashed")

# ═══════════════════════════════════════════════════════
# OUTPUT ARTIFACTS (right side)
# ═══════════════════════════════════════════════════════
# Place file artifacts along the pipeline

# ═══════════════════════════════════════════════════════
# LEGEND
# ═══════════════════════════════════════════════════════
legend_y = 0
draw_bg_region(0.5, legend_y, 25, 7.8, "#FFFFFF", "")
ax.text(13, legend_y + 7.3, "Legend — Agents, Skills & Design Principles",
        fontsize=14, fontweight="bold", color="#1a1a2e", ha="center",
        family="sans-serif")

# Legend entries
legend_items = [
    (C_CMD,    "Slash Commands",    "User entry points: /run, /recast, /recast-cf, /init, /stage, /review, /final, /publish"),
    (C_ORCH,   "Orchestrator",      "Master state manager; dispatches notebook_runner for each stage; reads config.yaml"),
    (C_STAGE,  "Notebook Stages",   "6 sequential Jupyter notebooks executed via nbconvert (30-min timeout per stage)"),
    (C_S4VAR,  "Stage 4 Variants",  "DoubleML (PLIR/PLIV/IRM) via /recast  OR  Causal Forest (CausalForestDML) via /recast-cf"),
    (C_GATE,   "Advisor Gate",      "3 independent validators: Code Auditor + Identification Checker + Data Validator (all must PASS)"),
    (C_REF,    "Referees 1-3",      "Isolated peer reviewers — Identification (7 items), DML/CF Methods (21 items), Robustness (8 items)"),
    (C_SYNTH,  "Synthesis Referee",  "First agent to see all 3 reports; deduplicates issues, ranks by severity (blocking > major > minor)"),
    (C_REV,    "Revision Agent",     "Only agent that edits paper.tex & code_build/; appends revision sections, never overwrites"),
    (C_FINAL,  "Final & Publish",    "Final Referee writes final_report.md; Publish generates Quarto website page"),
    (C_DECIDE, "Decision Points",    "Pipeline variant, gate pass/fail, blocking issues, max rounds reached"),
]

for i, (color, name, desc) in enumerate(legend_items):
    yy = legend_y + 6.5 - i * 0.65
    # Color swatch
    swatch = FancyBboxPatch((1.2, yy - 0.15), 0.5, 0.35, boxstyle="round,pad=0.05",
                             facecolor=color, edgecolor="#999", linewidth=0.8)
    ax.add_patch(swatch)
    ax.text(2.0, yy, name, fontsize=9, fontweight="bold", color="#1a1a2e",
            va="center", family="sans-serif")
    ax.text(6.0, yy, desc, fontsize=8, color="#555", va="center", family="sans-serif")

# Design principles
ax.text(13, legend_y + 0.3,
        "Design:  State = filesystem (no in-memory passing)  |  Referee isolation (independent reviews)  |  "
        "Append-only review history  |  Blocking issues trigger /stage 4 re-run  |  paper_spec.json read-only after Stage 1",
        fontsize=7.5, color="#777", ha="center", va="center", family="sans-serif",
        style="italic")

# ═══════════════════════════════════════════════════════
# Save
# ═══════════════════════════════════════════════════════
out = "C:/Users/qgallea/Dropbox/work/claude_code/causal_ml_extension/recast_pipeline.png"
fig.savefig(out, dpi=180, bbox_inches="tight", facecolor=fig.get_facecolor(), pad_inches=0.5)
plt.close()
print(f"Saved: {out}")
