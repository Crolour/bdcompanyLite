

-- �������� ���������

--������� ������� ������� � �������� (��������� ������)
 DELETE FROM tblClients WHERE ClientID = 1;

--���������� ������� ������ �� "���������"

UPDATE tblTasks SET [Status] = '���������' WHERE TaskID = 4;
 SELECT TaskID, Status FROM tblTasks WHERE TaskID = 4;

-- �������� ���������� ������� �������
SELECT * FROM tblProjects;

--�������� ����������� ����� ��������
SELECT * FROM tblProjectLogs;



-- ������� 
--1 �������� ������ ���� ����� ������������� ����������
SELECT t.TaskID, t.Description, t.Status, p.Name AS ProjectName
FROM tblEmployeeTaskAssignments eta
JOIN tblTasks t ON eta.TaskID = t.TaskID
JOIN tblProjects p ON t.ProjectID = p.ProjectID
WHERE eta.EmployeeID = 1;

--2 ����� ��� �������, � ������� ���� ������������� ������
SELECT DISTINCT p.ProjectID, p.Name, p.Status
FROM tblProjects p
JOIN tblTasks t ON p.ProjectID = t.ProjectID
WHERE t.Status <> '���������';

--3. ���������� ���������� ����� � ������� �������
SELECT p.ProjectID, p.Name, COUNT(t.TaskID) AS TaskCount
FROM tblProjects p
LEFT JOIN tblTasks t ON p.ProjectID = t.ProjectID
GROUP BY p.ProjectID, p.Name;

--				�������

-- �������
CREATE TABLE tblClients (
    ClientID INT IDENTITY(1,1) PRIMARY KEY,
    Name NVARCHAR(255) NOT NULL,
    ContactPerson NVARCHAR(255),
    Phone NVARCHAR(20),
    Email NVARCHAR(255)
);

-- �������
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

-- ������
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

-- ����������
CREATE TABLE tblEmployees (
    EmployeeID INT IDENTITY(1,1) PRIMARY KEY,
    FirstName NVARCHAR(100),
    LastName NVARCHAR(100),
    Position NVARCHAR(100),
    Department NVARCHAR(100),
    Phone NVARCHAR(20),
    Email NVARCHAR(255)
);

-- ������������� �������: ����� ������-��-������ ����� ������������ � ��������
CREATE TABLE tblEmployeeTaskAssignments (
    AssignmentID INT IDENTITY(1,1) PRIMARY KEY,
    EmployeeID INT NOT NULL,
    TaskID INT NOT NULL,
    CONSTRAINT FK_tblEmployeeTaskAssignments_tblEmployees FOREIGN KEY (EmployeeID)
        REFERENCES tblEmployees(EmployeeID),
    CONSTRAINT FK_tblEmployeeTaskAssignments_tblTasks FOREIGN KEY (TaskID)
        REFERENCES tblTasks(TaskID)
);

-- ����������� ������� �� ��������
CREATE TABLE tblProjectLogs (
    LogID INT IDENTITY(1,1) PRIMARY KEY,
    ProjectID INT,
    Action NVARCHAR(100),
    LogDate DATETIME DEFAULT GETDATE()
);


-- 2.  ��������


-- 2.1. ������ �������� �������, ���� � ���� ���� �������
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
        THROW 50001, '���������� ������� �������, ��� ��� � ���� ���� �������.', 1;
        RETURN;
    END

    DELETE FROM tblClients
    WHERE ClientID IN (SELECT ClientID FROM deleted);
END;
GO

-- 2.2. �������������� ���������� �������, ���� ��� ������ ���������
CREATE TRIGGER trgUpdateProjectStatusOnAllTasksCompleted
ON tblTasks
AFTER UPDATE
AS
BEGIN
    IF UPDATE(Status)
    BEGIN
        UPDATE p
        SET p.Status = '��������'
        FROM tblProjects p
        WHERE p.Status <> '��������'
          AND NOT EXISTS (
              SELECT 1
              FROM tblTasks t
              WHERE t.ProjectID = p.ProjectID AND t.Status <> '���������'
          );
    END
END;
GO

-- 2.3. ����������� ���������� ������ �������
CREATE TRIGGER trgLogNewProject
ON tblProjects
AFTER INSERT
AS
BEGIN
    INSERT INTO tblProjectLogs (ProjectID, Action)
    SELECT ProjectID, '�������� ����� ������'
    FROM inserted;
END;




INSERT INTO tblClients (Name, ContactPerson, Phone, Email) VALUES
('��� �������', '���� ������', '+7 987 654-32-10', 'ivan@gazprom.ru'),
('�� ����������', '����� ��������', '+7 900 123-45-67', 'maria@rosgaz.ru'),
('��� ������������', '������ ������', '+7 910 222-33-44', 'andrey@nizhgas.ru');


INSERT INTO tblProjects (Name, Description, StartDate, EndDate, Status, ClientID) VALUES
('���������� � ������', '������������� �������������� �����������', '2025-01-10', '2025-12-31', '� ������', 1),
('������������� ���� � ����������', '���������� ����������������� ������� ����', '2024-09-01', '2025-06-30', '� ������', 2),
('����� ��������� � ��������', '�������������� � ������������� ������� ���������', '2025-03-01', '2025-11-30', '� ������', 3);


INSERT INTO tblEmployees (FirstName, LastName, Position, Department, Phone, Email) VALUES
('���������', '�������', '������� �������', '��������������', '+7 900 111-22-33', 'smyrnow@energostroy.ru'),
('�����', '�������', '������', '�������������', '+7 901 222-33-44', 'petrovaelena@energostroy.ru'),
('�����', 'Ը�����', '������ �������', '�������������', '+7 902 333-44-55', 'fedorov@energostroy.ru'),
('���������', '�������', '���������', '�������', '+7 903 444-55-66', 'volkova@energostroy.ru'),
('�������', '��������', '�����', '�����������', '+7 904 555-66-77', 'kuznetsov@energostroy.ru');

INSERT INTO tblTasks (ProjectID, Description, StartDate, DueDate, Status) VALUES

(1, '���������� ������', '2025-01-10', '2025-02-28', '� ������'),
(1, '������� ����', '2025-03-01', '2025-06-30', '� ������'),
(1, '������������ �������', '2025-11-01', '2025-12-15', '�������'),

(2, '�������������� ����', '2024-09-01', '2024-10-31', '���������'),
(2, '�������� ������', '2024-11-01', '2025-02-28', '� ������'),
(2, '������ ������������', '2025-03-01', '2025-05-31', '� ������'),

(3, '�������������� ���������', '2025-03-01', '2025-04-30', '� ������'),
(3, '������� ����������', '2025-05-01', '2025-06-30', '�������'),
(3, '������������� �������', '2025-07-01', '2025-10-31', '�������');


INSERT INTO tblEmployeeTaskAssignments (EmployeeID, TaskID) VALUES
-- ������ 1 (���������� ������)
(1, 1), (2, 1),

-- ������ 2 (������� ����)
(2, 2), (3, 2),

-- ������ 4 (�������������� ����)
(1, 4),

-- ������ 5 (�������� ������)
(2, 5), (3, 5),

-- ������ 7 (�������������� ���������)
(1, 7);


-- ���������� ������ ����������
INSERT INTO tblEmployeeTaskAssignments (EmployeeID, TaskID)
VALUES (1, 1);
