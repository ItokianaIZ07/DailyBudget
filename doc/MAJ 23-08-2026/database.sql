CREATE TABLE monthly_salary (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    month INTEGER NOT NULL,
    year INTEGER NOT NULL,
    salary REAL NOT NULL,

    UNIQUE(month, year),

    CHECK(month BETWEEN 1 AND 12),
    CHECK(salary >= 0)
);

CREATE TABLE daily_budget (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    date TEXT NOT NULL,
    amount REAL NOT NULL,

    UNIQUE(date),

    CHECK(amount >= 0)
);

-- requête pour obtenir le budget  et les dépenses d'une journée
SELECT
    db.date,
    db.amount AS budget,
    COALESCE(SUM(e.amount), 0) AS spent
FROM daily_budget db
LEFT JOIN expenses e
    ON DATE(e.date) = db.date
WHERE db.date = ?
GROUP BY db.date, db.amount;

-- Requête pour le budget total d'un mois
SELECT COALESCE(SUM(amount), 0) AS total_budget
FROM daily_budget
WHERE strftime('%Y', date) = ?
  AND strftime('%m', date) = ?;