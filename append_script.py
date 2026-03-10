
with open('data_manager_sqlite.py', 'a', encoding='utf-8') as f1:
    with open('data_manager_sqlite_append.py', 'r', encoding='utf-8') as f2:
        f1.write('\n' + f2.read())
print("Append successful")
