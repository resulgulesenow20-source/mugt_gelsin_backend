import json
import os

log_path = r"C:\Users\dell\.gemini\antigravity\brain\37c48893-1741-459a-808b-258713d04e82\.system_generated\logs\transcript_full.jsonl"
ui_texts_path = r"c:\Users\dell\mugyt_kampanyalar\ui_texts.py"

ui_texts_content = None

with open(log_path, "r", encoding="utf-8") as f:
    for line in f:
        try:
            data = json.loads(line)
            if "tool_calls" in data:
                for call in data["tool_calls"]:
                    if call["name"] == "write_to_file":
                        args = call["args"]
                        if args.get("TargetFile") == ui_texts_path:
                            ui_texts_content = args.get("CodeContent")
        except:
            pass

if ui_texts_content:
    with open(ui_texts_path, "w", encoding="utf-8") as f:
        f.write(ui_texts_content)
    print("ui_texts.py restored.")
