import sqlparse
sql = input("Enter SQL: ")
print(sqlparse.format(sql, reindent=True, keyword_case='upper'))
