-- Insert some test data into the database...
INSERT OR IGNORE INTO Tags VALUES
    (1, 'Favorite'),
    (2, 'Test');

INSERT OR IGNORE INTO Recipes VALUES
    (1, 'Pizza', 'Round and tasty', NULL),
    (2, 'Spaghetti Carbonara', 'Smushy and tasty', NULL),
    (3, 'Risotto', 'Silky and tasty', NULL),
    (4, 'Guacamole', 'Some people call it guac.', '# Guacamole

Some people call it guac.

*sauce, vegan*

**4 Servings, 200g**

---

- *1* avocado
- *.5 teaspoon* salt
- *1 1/2 pinches* red pepper flakes
- lemon juice

---

Remove flesh from avocado and roughly mash with fork. Season to taste
with salt, pepper and lemon juice.');

INSERT OR IGNORE INTO RecipeTags VALUES
    (1, 2),
    (2, 2),
    (3, 2),
    (2, 2),
    (3, 2);

