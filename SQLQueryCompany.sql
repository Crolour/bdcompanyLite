

-- Проверка триггеров

--Попытка удалить клиента с проектом (ожидается ошибка)
 DELETE FROM tblClients WHERE ClientID = 1;

--Обновление статуса задачи на "выполнена"

UPDATE tblTasks SET [Status] = 'выполнена' WHERE TaskID = 4;
 SELECT TaskID, Status FROM tblTasks WHERE TaskID = 4;

-- Проверка обновления статуса проекта
SELECT * FROM tblProjects;

--Проверка логирования новых проектов
SELECT * FROM tblProjectLogs;



-- Запросы 
--1 Получить список всех задач определенного сотрудника
SELECT t.TaskID, t.Description, t.Status, p.Name AS ProjectName
FROM tblEmployeeTaskAssignments eta
JOIN tblTasks t ON eta.TaskID = t.TaskID
JOIN tblProjects p ON t.ProjectID = p.ProjectID
WHERE eta.EmployeeID = 1;

--2 Найти все проекты, у которых есть незавершённые задачи
SELECT DISTINCT p.ProjectID, p.Name, p.Status
FROM tblProjects p
JOIN tblTasks t ON p.ProjectID = t.ProjectID
WHERE t.Status <> 'выполнена';

--3. Подсчитать количество задач у каждого проекта
SELECT p.ProjectID, p.Name, COUNT(t.TaskID) AS TaskCount
FROM tblProjects p
LEFT JOIN tblTasks t ON p.ProjectID = t.ProjectID
GROUP BY p.ProjectID, p.Name;

--				Таблицы

-- Клиенты
CREATE TABLE tblClients (
    ClientID INT IDENTITY(1,1) PRIMARY KEY,
    Name NVARCHAR(255) NOT NULL,
    ContactPerson NVARCHAR(255),
    Phone NVARCHAR(20),
    Email NVARCHAR(255)
);

-- Проекты
CREATE TABLE tblProjects (
    ProjectID INT IDENTITY(1,1) PRIMARY KEY,
    Name NVARCHAR(255) NOT NULL,
    Description NVARCHAR(MAX),
    StartDate DATE,
    EndDate DATE,
    Status NVARCHAR(50),
    ClientID INT NOT NULL,
    CONSTRAINT FK_tblProjects_tblClients FOREIGN KEY (ClientID)
        REFERENCES tblClients(ClientID)
);

-- Задачи
CREATE TABLE tblTasks (
    TaskID INT IDENTITY(1,1) PRIMARY KEY,
    ProjectID INT NOT NULL,
    Description NVARCHAR(MAX),
    StartDate DATE,
    DueDate DATE,
    Status NVARCHAR(50),
    CONSTRAINT FK_tblTasks_tblProjects FOREIGN KEY (ProjectID)
        REFERENCES tblProjects(ProjectID)
);

-- Сотрудники
CREATE TABLE tblEmployees (
    EmployeeID INT IDENTITY(1,1) PRIMARY KEY,
    FirstName NVARCHAR(100),
    LastName NVARCHAR(100),
    Position NVARCHAR(100),
    Department NVARCHAR(100),
    Phone NVARCHAR(20),
    Email NVARCHAR(255)
);

-- Промежуточная таблица: связь многие-ко-многим между сотрудниками и задачами
CREATE TABLE tblEmployeeTaskAssignments (
    AssignmentID INT IDENTITY(1,1) PRIMARY KEY,
    EmployeeID INT NOT NULL,
    TaskID INT NOT NULL,
    CONSTRAINT FK_tblEmployeeTaskAssignments_tblEmployees FOREIGN KEY (EmployeeID)
        REFERENCES tblEmployees(EmployeeID),
    CONSTRAINT FK_tblEmployeeTaskAssignments_tblTasks FOREIGN KEY (TaskID)
        REFERENCES tblTasks(TaskID)
);

-- Логирование событий по проектам
CREATE TABLE tblProjectLogs (
    LogID INT IDENTITY(1,1) PRIMARY KEY,
    ProjectID INT,
    Action NVARCHAR(100),
    LogDate DATETIME DEFAULT GETDATE()
);


-- 2.  триггеры


-- 2.1. Запрет удаления клиента, если у него есть проекты
CREATE TRIGGER trgPreventClientDeleteIfProjectsExist
ON tblClients
INSTEAD OF DELETE
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM deleted d
        JOIN tblProjects p ON d.ClientID = p.ClientID
    )
    BEGIN
        THROW 50001, 'Невозможно удалить клиента, так как у него есть проекты.', 1;
        RETURN;
    END

    DELETE FROM tblClients
    WHERE ClientID IN (SELECT ClientID FROM deleted);
END;
GO

-- 2.2. Автоматическое завершение проекта, если все задачи выполнены
CREATE TRIGGER trgUpdateProjectStatusOnAllTasksCompleted
ON tblTasks
AFTER UPDATE
AS
BEGIN
    IF UPDATE(Status)
    BEGIN
        UPDATE p
        SET p.Status = 'завершён'
        FROM tblProjects p
        WHERE p.Status <> 'завершён'
          AND NOT EXISTS (
              SELECT 1
              FROM tblTasks t
              WHERE t.ProjectID = p.ProjectID AND t.Status <> 'выполнена'
          );
    END
END;
GO

-- 2.3. Логирование добавления нового проекта
CREATE TRIGGER trgLogNewProject
ON tblProjects
AFTER INSERT
AS
BEGIN
    INSERT INTO tblProjectLogs (ProjectID, Action)
    SELECT ProjectID, 'Добавлен новый проект'
    FROM inserted;
END;




INSERT INTO tblClients (Name, ContactPerson, Phone, Email) VALUES
('ООО Газпром', 'Иван Петров', '+7 987 654-32-10', 'ivan@gazprom.ru'),
('АО РосГазСеть', 'Мария Смирнова', '+7 900 123-45-67', 'maria@rosgaz.ru'),
('МУП Нижегородгаз', 'Андрей Иванов', '+7 910 222-33-44', 'andrey@nizhgas.ru');


INSERT INTO tblProjects (Name, Description, StartDate, EndDate, Status, ClientID) VALUES
('Газопровод в Нижнем', 'Строительство магистрального газопровода', '2025-01-10', '2025-12-31', 'в работе', 1),
('Реконструкция сети в Дзержинске', 'Обновление распределительной газовой сети', '2024-09-01', '2025-06-30', 'в работе', 2),
('Новая котельная в Арзамасе', 'Проектирование и строительство газовой котельной', '2025-03-01', '2025-11-30', 'в планах', 3);


INSERT INTO tblEmployees (FirstName, LastName, Position, Department, Phone, Email) VALUES
('Александр', 'Смирнов', 'Главный инженер', 'Проектирование', '+7 900 111-22-33', 'smyrnow@energostroy.ru'),
('Елена', 'Петрова', 'Прораб', 'Строительство', '+7 901 222-33-44', 'petrovaelena@energostroy.ru'),
('Игорь', 'Фёдоров', 'Мастер участка', 'Строительство', '+7 902 333-44-55', 'fedorov@energostroy.ru'),
('Анастасия', 'Волкова', 'Бухгалтер', 'Финансы', '+7 903 444-55-66', 'volkova@energostroy.ru'),
('Дмитрий', 'Кузнецов', 'Юрист', 'Юридический', '+7 904 555-66-77', 'kuznetsov@energostroy.ru');

INSERT INTO tblTasks (ProjectID, Description, StartDate, DueDate, Status) VALUES

(1, 'Подготовка трассы', '2025-01-10', '2025-02-28', 'в работе'),
(1, 'Укладка труб', '2025-03-01', '2025-06-30', 'в планах'),
(1, 'Тестирование системы', '2025-11-01', '2025-12-15', 'ожидает'),

(2, 'Проектирование сети', '2024-09-01', '2024-10-31', 'выполнена'),
(2, 'Земляные работы', '2024-11-01', '2025-02-28', 'в работе'),
(2, 'Монтаж оборудования', '2025-03-01', '2025-05-31', 'в планах'),

(3, 'Проектирование котельной', '2025-03-01', '2025-04-30', 'в планах'),
(3, 'Закупка материалов', '2025-05-01', '2025-06-30', 'ожидает'),
(3, 'Строительство объекта', '2025-07-01', '2025-10-31', 'ожидает');


INSERT INTO tblEmployeeTaskAssignments (EmployeeID, TaskID) VALUES
-- Задача 1 (Подготовка трассы)
(1, 1), (2, 1),

-- Задача 2 (Укладка труб)
(2, 2), (3, 2),

-- Задача 4 (Проектирование сети)
(1, 4),

-- Задача 5 (Земляные работы)
(2, 5), (3, 5),

-- Задача 7 (Проектирование котельной)
(1, 7);


-- Назначение задачи сотруднику
INSERT INTO tblEmployeeTaskAssignments (EmployeeID, TaskID)
VALUES (1, 1);
