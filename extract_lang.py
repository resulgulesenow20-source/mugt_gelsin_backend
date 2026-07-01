import json

log_path = r"C:\Users\dell\.gemini\antigravity\brain\37c48893-1741-459a-808b-258713d04e82\.system_generated\logs\transcript_full.jsonl"
out_path = r"C:\Users\dell\mugut_gelsin\lang_mods.txt"

with open(log_path, "r", encoding="utf-8") as f, open(out_path, "w", encoding="utf-8") as out:
    for line in f:
        try:
            data = json.loads(line)
            if "tool_calls" in data:
                for call in data["tool_calls"]:
                    if call["name"] in ["replace_file_content", "multi_replace_file_content"]:
                        args = call["args"]
                        if "language_provider.dart" in args.get("TargetFile", ""):
                            out.write(json.dumps(args, indent=2, ensure_ascii=False))
                            out.write("\n\n")
        except:
            pass
print("Done extracting lang mods.")
