
# База данных компании для управления проектами


![ERD-Diagram](https://github.com/Crolour/bdcompanyLite/blob/master/{7B950A9E-C32E-40EE-A182-4681420AFD3C}.png)


## Описание
Эта база данных разработана для управления проектами, задачами, сотрудниками и клиентами. Она подходит для строительных, инженерных или проектных компаний.

## Структура

### Таблицы:
- **tblClients** — клиенты
- **tblProjects** — проекты
- **tblTasks** — задачи по проектам
- **tblEmployees** — сотрудники
- **tblEmployeeTaskAssignments** — связь "многие ко многим" между задачами и сотрудниками
- **tblProjectLogs** — лог событий по проектам
  
## Запросы 
**1 Получить список всех задач определенного сотрудника**
``` sql 
SELECT t.TaskID, t.Description, t.Status, p.Name AS ProjectName
FROM tblEmployeeTaskAssignments eta
JOIN tblTasks t ON eta.TaskID = t.TaskID
JOIN tblProjects p ON t.ProjectID = p.ProjectID
WHERE eta.EmployeeID = 1;
```

** 2 Найти все проекты, у которых есть незавершённые задачи ***
``` sql
SELECT DISTINCT p.ProjectID, p.Name, p.Status
FROM tblProjects p
JOIN tblTasks t ON p.ProjectID = t.ProjectID
WHERE t.Status <> 'выполнена';
```

** 3. Подсчитать количество задач у каждого проекта**
``` sql
SELECT p.ProjectID, p.Name, COUNT(t.TaskID) AS TaskCount
FROM tblProjects p
LEFT JOIN tblTasks t ON p.ProjectID = t.ProjectID
GROUP BY p.ProjectID, p.Name;
```
## Триггеры

1. **trgPreventClientDeleteIfProjectsExist**  
   Запрещает удаление клиента, если у него есть проекты.

2. **trgUpdateProjectStatusOnAllTasksCompleted**  
   Автоматически меняет статус проекта на "завершён", если все задачи выполнены.

3. **trgLogNewProject**  
   Логирует добавление нового проекта.

## Примеры запросов

Попытка удалить клиента с проектом (вызовет ошибку):
```sql
DELETE FROM tblClients WHERE ClientID = 1;
```

Обновление статуса задачи:
```sql
UPDATE tblTasks SET Status = 'выполнена' WHERE TaskID = 4;
SELECT TaskID, Status FROM tblTasks WHERE TaskID = 4;
```

Проверка обновления статуса проекта:
```sql
SELECT * FROM tblProjects;
```

Проверка логов:
```sql
SELECT * FROM tblProjectLogs;
```

## Технические требования
- **СУБД:** Microsoft SQL Server 2012+
- **Инструменты:** SSMS или другая IDE для работы с T-SQL
