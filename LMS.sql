/*Library Management System*/
CREATE DATABASE IF NOT EXISTS library;
USE library;

CREATE TABLE Books (
    BookID INT AUTO_INCREMENT PRIMARY KEY,
    Title VARCHAR(200),
    Author VARCHAR(200),
    Category VARCHAR(20),
    Publisher VARCHAR(200),
    PublishedYear YEAR,
    AvailableCopies INT DEFAULT 1
);
CREATE TABLE Members (
    MemberID INT AUTO_INCREMENT PRIMARY KEY,
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50),
    Gender CHAR(1) CHECK (Gender IN ('M', 'F', 'O')),
    PhoneNumber VARCHAR(15) UNIQUE,
    Email VARCHAR(100) UNIQUE,
    JoinDate DATE DEFAULT (CURRENT_DATE)
);
CREATE TABLE BooksIssued (
    IssueID INT AUTO_INCREMENT PRIMARY KEY,
    BookID INT,
    MemberID INT,
    IssueDate DATE DEFAULT (CURRENT_DATE),
    DueDate DATE,

    CONSTRAINT fk_BOOK
    FOREIGN KEY (BookID) REFERENCES Books(BookID),

    CONSTRAINT fk_MEMBER
    FOREIGN KEY (MemberID) REFERENCES Members(MemberID)
);

CREATE TABLE BooksReturned (
    ReturnID INT AUTO_INCREMENT PRIMARY KEY,
    IssueID INT,
    ReturnDate DATE DEFAULT (CURRENT_DATE),

    CONSTRAINT fk_ISSUE
    FOREIGN KEY (IssueID) REFERENCES BooksIssued(IssueID)
);

INSERT INTO Books (Title, Author, Category, Publisher, PublishedYear, AvailableCopies)
VALUES
('The Alchemist', 'Paulo Coelho', 'Fiction', 'Harper', 1988, 5),
('Clean Code', 'Robert C. Martin', 'Programming', 'Prentice Hall', 2008, 4),
('Database System Concepts', 'Abraham Silberschatz', 'Education', 'McGraw Hill', 2019, 3),
('Atomic Habits', 'James Clear', 'Self Help', 'Penguin', 2018, 6),
('The Hobbit', 'J.R.R. Tolkien', 'Fantasy', 'HarperCollins', 1937, 2),
('Python Crash Course', 'Eric Matthes', 'Programming', 'No Starch Press', 2023, 5),
('Introduction to Algorithms', 'Thomas H. Cormen', 'Education', 'MIT Press', 2022, 2),
('Think Like a Monk', 'Jay Shetty', 'Self Help', 'Simon & Schuster', 2020, 4);

INSERT INTO Members(FirstName, LastName, Gender, PhoneNumber, Email)
VALUES
('Arka', 'Dutta', 'M', '9876543210', 'arka@gmail.com'),
('Rahul', 'Sharma', 'M', '9876543211', 'rahul@gmail.com'),
('Priya', 'Singh', 'F', '9876543212', 'priya@gmail.com'),
('Sneha', 'Roy', 'F', '9876543213', 'sneha@gmail.com'),
('Amit', 'Das', 'M', '9876543214', 'amit@gmail.com'),
('Neha', 'Verma', 'F', '9876543215', 'neha@gmail.com'),
('Rohan', 'Paul', 'M', '9876543216', 'rohan@gmail.com'),
('Ananya', 'Ghosh', 'F', '9876543217', 'ananya@gmail.com');

INSERT INTO BooksIssued(BookID, MemberID, IssueDate, DueDate)
VALUES
(1, 2, '2026-07-01', '2026-07-15'),
(3, 1, '2026-07-03', '2026-07-17'),
(5, 4, '2026-07-05', '2026-07-19'),
(2, 6, '2026-07-06', '2026-07-20'),
(7, 3, '2026-07-08', '2026-07-22'),
(4, 8, '2026-07-10', '2026-07-24');

INSERT INTO BooksReturned(IssueID, ReturnDate)
VALUES
(1, '2026-07-12'),
(3, '2026-07-18'),
(6, '2026-07-21');

-- SOME QUERIES TO CHECK THE DATA
SELECT * FROM Books;
SELECT * FROM Members;
SELECT * FROM BooksIssued;
SELECT * FROM BooksReturned;
SELECT COUNT(*) FROM Books;
SELECT COUNT(*) FROM Members;
SELECT COUNT(*) FROM BooksIssued;
SELECT COUNT(*) FROM BooksReturned;
SELECT Title, Author
FROM Books;
SELECT * FROM Members
WHERE Gender = 'F';
SELECT * FROM Books
ORDER BY PublishedYear DESC;

/*====================================================
  Aggregate Queries
====================================================*/
SELECT COUNT(*) FROM Books; --Total number of books.
SELECT AVG(AvailableCopies) FROM Books;--Average available copies.
SELECT MAX(publishedYear) FROM Books; --Maximum published year.
SELECT COUNT(*), Category FROM Books --Count books in each category.
GROUP BY Category;
/*====================================================
  Join Queries
====================================================*/
SELECT m.FirstName, m.LastName ,b.Title AS BookName, bi.IssueDate, bi.DueDate /*Which member has issued which book?*/
FROM books AS b
JOIN booksissued AS bi ON b.BookID = bi.BookID
JOIN members AS m ON bi.MemberID = m.MemberID;

SELECT m.FirstName, m.LastName ,b.Title AS BookName, bi.IssueDate, bi.DueDate /*Which books have been returned?*/
FROM books AS b
JOIN booksissued AS bi ON b.BookID = bi.BookID
JOIN members AS m ON bi.MemberID = m.MemberID
JOIN booksreturned AS br ON bi.IssueID = br.IssueID
WHERE br.ReturnDate IS NOT NULL;

SELECT
    m.LastName,b.Title AS BookName, bi.IssueDate, bi.DueDate /*Which books are currently issued?*/
FROM BooksIssued AS bi
JOIN Books AS b
    ON bi.BookID = b.BookID
JOIN Members AS m
    ON bi.MemberID = m.MemberID
LEFT JOIN BooksReturned AS br
    ON bi.IssueID = br.IssueID
WHERE br.IssueID IS NULL;

SELECT
    m.LastName,b.Title AS BookName, bi.IssueDate, bi.DueDate /*Which members haven't returned their books?*/
FROM BooksIssued AS bi
JOIN Members AS m
    ON bi.MemberID = m.MemberID
JOIN Books AS b
    ON bi.BookID = b.BookID
LEFT JOIN BooksReturned AS br
    ON bi.IssueID = br.IssueID
WHERE br.IssueID IS NULL;

SELECT b.Title AS BookName, COUNT(bi.IssueID) AS TimesIssued /*Which books are most frequently issued?*/
FROM BooksIssued AS bi
JOIN Books AS b
    ON bi.BookID = b.BookID
GROUP BY b.BookID, b.Title
ORDER BY TimesIssued DESC
LIMIT 5;

SELECT CONCAT(m.FirstName, ' ', m.LastName) AS MemberName,COUNT(bi.IssueID) AS TimesIssued /*Member who borrowed the most books.*/
FROM BooksIssued AS bi
JOIN Books AS b
    ON bi.BookID = b.BookID
JOIN Members AS m
    ON bi.MemberID = m.MemberID
GROUP BY m.MemberID, m.FirstName, m.LastName
ORDER BY TimesIssued DESC;

SELECT m.MemberID, CONCAT(m.FirstName, ' ', m.LastName) AS MemberName /*Members who never borrowed a book.*/
FROM members AS m
LEFT JOIN BooksIssued AS bi
    ON m.MemberID = bi.MemberID
WHERE bi.IssueID IS NULL;

SELECT b.Title AS BookName,bi.DueDate /*Overdue books.*/
FROM BooksIssued AS bi
JOIN Books AS b
    ON bi.BookID = b.BookID
LEFT JOIN BooksReturned AS br
    ON bi.IssueID = br.IssueID
WHERE bi.DueDate < CURRENT_DATE AND br.ReturnDate IS NULL;


