import streamlit as st
import json
import pandas as pd
import subprocess

st.set_page_config(page_title="Advanced Spark Dashboard", layout="wide")

st.title("🎮 Advanced Interactive Spark Analytics")

# ------------------------
# RUN FUNCTION
# ------------------------
def run(query, p1=None, p2=None):
    cmd = ["Rscript", "spark/run_stats.R", query]
    if p1:
        cmd.append(p1)
    if p2:
        cmd.append(p2)

    subprocess.run(cmd)

    with open("spark/output.json") as f:
        return json.load(f)

# =========================
# SECTION 1 — GAME ANALYTICS
# =========================
st.header("🎯 Game Analytics")

game = st.text_input("Enter Game Name", "Chess")

col1, col2, col3 = st.columns(3)

if col1.button("Avg Score"):
    data = run("avg_score", game)
    st.metric("Average Score", data["avg"][0]["avg_score"])

if col2.button("Max Score"):
    data = run("max_score", game)
    st.metric("Max Score", data["max"][0]["max_score"])

if col3.button("Min Score"):
    data = run("min_score", game)
    st.metric("Min Score", data["min"][0]["min_score"])

# ------------------------
# GROUP + SUM + COUNT
# ------------------------
st.subheader("📊 Game Summary")

if st.button("Game Summary"):
    data = run("game_summary")
    df = pd.DataFrame(data["summary"])
    st.dataframe(df)
    st.bar_chart(df.set_index("game_name")["avg_score"])

# =========================
# SECTION 2 — PLAYER ANALYTICS
# =========================
st.header("👤 Player Analytics")

player = st.text_input("Enter Player Name")

col1, col2, col3 = st.columns(3)

if col1.button("Player Stats"):
    data = run("player_stats", player)
    st.dataframe(pd.DataFrame(data["player"]))

if col2.button("Player Matches"):
    data = run("player_matches", player)
    st.dataframe(pd.DataFrame(data["matches"]))

if col3.button("Win Count"):
    data = run("win_count", player)
    st.write(data["wins"])

# =========================
# SECTION 3 — FILTERS
# =========================
st.header("🔍 Dynamic Filters")

game_filter = st.text_input("Filter by Game")
min_score = st.number_input("Min Score", value=1000)

if st.button("Apply Filter"):
    data = run("filter_advanced", game_filter, str(min_score))
    st.dataframe(pd.DataFrame(data["filter"]))

# =========================
# SECTION 4 — SORTING
# =========================
st.header("📊 Sorting & Ranking")

if st.button("Top Players"):
    data = run("top_players")
    st.dataframe(pd.DataFrame(data["top"]))

if st.button("Bottom Players"):
    data = run("bottom_players")
    st.dataframe(pd.DataFrame(data["bottom"]))

# =========================
# SECTION 5 — ADVANCED STATS
# =========================
st.header("📈 Advanced Statistics")

col1, col2, col3 = st.columns(3)

if col1.button("Standard Deviation"):
    data = run("sd")
    st.write(data["sd"])

if col2.button("Median Score"):
    data = run("median")
    st.write(data["median"])

if col3.button("Total Score"):
    data = run("sum")
    st.write(data["sum"])

if st.button("Distinct Players"):
    data = run("distinct")
    st.write(data["distinct"])

if st.button("First & Last"):
    data = run("firstlast")
    st.write(data["firstlast"])

# =========================
# SECTION 6 — EXTRA (SELECT)
# =========================
st.header("🧾 Select Columns")

if st.button("Show Selected Columns"):
    data = run("select_cols")
    st.dataframe(pd.DataFrame(data["select"]))

# =========================
# SECTION 7 — BASE R (FOR MARKS)
# =========================
st.header("🧠 Base R Concepts")

if st.button("Run Base R Demo"):
    data = run("baseR")
    st.json(data["baseR"])