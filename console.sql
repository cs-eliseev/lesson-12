-- 1. Сколько забитых голов командой России в играх
SELECT t.name AS team, COUNT(s.game_id) AS game, SUM(s.goals) AS goals
FROM team AS t
  LEFT JOIN side AS s ON s.team_id = t.id
WHERE t.name = 'Россия'
GROUP BY t.name;

-- 2. Топ 5 команд с наибольшим количеством карточек
SELECT t.name, COUNT(*) AS carts
FROM action AS a
  LEFT JOIN player AS p ON p.id = a.player_id
  LEFT JOIN team AS t ON t.id = p.team_id
WHERE a.type IN ('red', 'yellow')
GROUP BY t.name
ORDER BY carts DESC
LIMIT 5;

-- 3. Количество играков по каждой заявленной позиции
SELECT role, COUNT(role) AS cnt
FROM player
GROUP BY role
ORDER BY cnt ASC;

-- 4. Игроки забившие более 1 гола в одном матче
SELECT t.name AS team, p.name, p.surname, m.goals
FROM (
  SELECT a.player_id, COUNT(a.player_id) AS goals
  FROM action AS a
  WHERE a.type IN ('goal', 'penalty goal')
  GROUP BY a.game_id, a.player_id
  HAVING COUNT(a.player_id) > 1
) AS m
  LEFT JOIN player AS p ON p.id = m.player_id
  LEFT JOIN team AS t ON t.id = p.team_id
ORDER BY m.goals DESC;

-- 5. Самый забивающий игрок
SELECT t.name AS team, p.name, p.surname, m.goals
FROM (
       SELECT a.player_id, COUNT(a.player_id) AS goals
       FROM action AS a
       WHERE a.type IN ('goal', 'penalty goal')
       GROUP BY a.player_id
       ORDER BY goals DESC
       LIMIT 1
     ) AS m
  LEFT JOIN player AS p ON p.id = m.player_id
  LEFT JOIN team AS t ON t.id = p.team_id;

-- 6. Самый молодой игрок
SELECT t.name AS team, p.name, p.surname, age(p.birthday)
FROM player AS p
  LEFT JOIN team AS t ON p.team_id = t.id
ORDER BY p.birthday DESC
LIMIT 1;

-- 7. Самый зрелещный матч
SELECT st.name AS stadium, g.date, t.name AS team, s.result, s.goals
FROM (
  SELECT a.game_id, SUM(CASE WHEN a.type = 'goal' THEN 2 ELSE 1 END) AS point
  FROM action AS a
  WHERE a.type IN ('goal', 'penalty goal')
  GROUP BY a.game_id
  ORDER BY point DESC
  LIMIT 1
) AS m
  LEFT JOIN side AS s ON s.game_id = m.game_id
  LEFT JOIN team AS t ON t.id = s.team_id
  LEFT JOIN game AS g ON g.id = s.game_id
  LEFT JOIN stadium AS st ON st.id = g.stadium_id;

-- 8. Самая интерестная группа
SELECT g.name, SUM(s.goals) as goals
FROM (
       SELECT a.game_id, SUM(CASE WHEN a.type = 'goal' THEN 2 ELSE 1 END) AS point
       FROM action AS a
       WHERE a.type IN ('goal', 'penalty goal')
       GROUP BY a.game_id
     ) AS m
  LEFT JOIN side AS s ON s.game_id = m.game_id
  LEFT JOIN team AS t ON t.id = s.team_id
  LEFT JOIN "group" AS g ON g.id = t.group_id
GROUP BY g.name
ORDER BY SUM(m.point) DESC;

-- 9. Средний возраст игроков команд
SELECT t.name AS team, AVG(AGE(birthday)) as age_avg
FROM player AS p
  LEFT JOIN team AS t ON t.id = p.team_id
GROUP BY t.name
ORDER BY age_avg;

-- 10. Список игроков удаленных во время матча
SELECT t.name AS team, p.name, p.surname
FROM (
  SELECT a.player_id, a.game_id
  FROM action AS a
  WHERE a.type IN ('yellow', 'red')
  GROUP BY a.game_id, a.player_id
  HAVING SUM(CASE WHEN a.type = 'red' THEN 2 ELSE 1 END) > 1
) AS m
  LEFT JOIN player AS p ON p.id = m.player_id
  LEFT JOIN team AS t ON t.id = p.team_id;