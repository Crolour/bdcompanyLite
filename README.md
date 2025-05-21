
# База данных компании для управления проектами


![Diagram](https://github.com/Crolour/bdcompanyLite/blob/master/{7B950A9E-C32E-40EE-A182-4681420AFD3C}.png)


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

## Триггеры

1. ```**trgPreventClientDeleteIfProjectsExist**  
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
