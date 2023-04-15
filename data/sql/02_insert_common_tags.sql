-- Insert some test data into the database...
INSERT OR IGNORE INTO Tags VALUES
    (1, 'Favorite'),
    (2, 'Test');

INSERT OR IGNORE INTO Recipes VALUES
    (1, 'Pizza', 'Round and tasty', NULL),
    (2, 'Spaghetti Carbonara', 'Smushy and tasty', NULL),
    (3, 'Risotto', 'Silky and tasty', NULL);

INSERT OR IGNORE INTO RecipeTags VALUES
    (1, 2),
    (2, 2),
    (3, 2),
    (2, 2),
    (3, 2);

