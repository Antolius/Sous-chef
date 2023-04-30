/*
* SPDX-License-Identifier: GPL-3.0-or-later
* SPDX-FileCopyrightText: 2023 Josip Antoliš <josip.antolis@protonmail.com>
*/

namespace Souschef.ParsingTests {

    public void add_funcs () {
        Test.add_func ("/Parsing/recipe", test_recipe);
    }

    void test_recipe () {
        var given_recipe = """# Title

The description describes this recipe. It is delicious!

It can have multiple lines an may even include pictures.

<img src="../logo/recipemd-mark.svg" />

*vegetarian, vegan, not a real recipe*

**5 cups, 20 ml, 5,5 Tassen**

---

- *5* ungrouped ingredient
- *5.2 ml* grouped ingredient

## Group 1

- *1 ⅕* [link ingredient](./ingredients.md)
- unit is optional

### Subgroup 1.1

- *1.25 ml* ingredient

## Group 2

- text isn't optional
- *hey* amount is valid without factor

---

Instructions are very instructive.""";
        var parser = new RecipeParser (0, given_recipe);
        var actual = parser.parse ();
        assert_nonnull (actual);

        assert_cmpstr (actual.title, CompareOperator.EQ, "Title");

        assert_cmpstr (actual.description, CompareOperator.EQ, """The description describes this recipe. It is delicious!

It can have multiple lines an may even include pictures.

<img src="../logo/recipemd-mark.svg" />""");

        var tags = actual.tags;
        assert_nonnull (tags);
        assert_cmpint (tags.size, CompareOperator.EQ, 3);
        assert_cmpstr (tags.get(0), CompareOperator.EQ, "vegetarian");
        assert_cmpstr (tags.get(1), CompareOperator.EQ, "vegan");
        assert_cmpstr (tags.get(2), CompareOperator.EQ, "not a real recipe");

        var yields = actual.yields;
        assert_nonnull (yields);
        assert_cmpint (yields.size, CompareOperator.EQ, 3);
        assert_cmpfloat (yields[0].value, CompareOperator.EQ, 5.0);
        assert_nonnull (yields[0].unit);
        assert_cmpstr (yields[0].unit.name, CompareOperator.EQ, "cups");
        assert_cmpfloat (yields[1].value, CompareOperator.EQ, 20.0);
        assert_nonnull (yields[1].unit);
        assert_cmpstr (yields[1].unit.name, CompareOperator.EQ, "ml");
        assert_cmpfloat (yields[1].value, CompareOperator.EQ, 20.0);
        assert_nonnull (yields[1].unit);
        assert_cmpstr (yields[1].unit.name, CompareOperator.EQ, "ml");
        assert_cmpfloat (yields[2].value, CompareOperator.EQ, 5.5);
        assert_nonnull (yields[2].unit);
        assert_cmpstr (yields[2].unit.name, CompareOperator.EQ, "Tassen");

        var groups = actual.ingredient_groups;
        assert_nonnull (groups);
        assert_cmpint (groups.size, CompareOperator.EQ, 4);

        var group = groups[0];
        assert_nonnull (group);
        assert_null (group.title);
        assert_nonnull (group.ingredients);
        assert_cmpint (group.ingredients.size, CompareOperator.EQ, 2);

        // - *5* ungrouped ingredient
        var ing = group.ingredients[0];
        assert_nonnull (ing);
        assert_nonnull (ing.amount);
        assert_cmpfloat (ing.amount.value, CompareOperator.EQ, 5.0);
        assert_null (ing.amount.unit);
        assert_cmpstr (ing.name, CompareOperator.EQ, "ungrouped ingredient");

        // - *5.2 ml* grouped ingredient
        ing = group.ingredients[1];
        assert_nonnull (ing);
        assert_nonnull (ing.amount);
        assert_cmpfloat (ing.amount.value, CompareOperator.EQ, 5.2);
        assert_nonnull (ing.amount.unit);
        assert_cmpstr (ing.amount.unit.name, CompareOperator.EQ, "ml");
        assert_cmpstr (ing.name, CompareOperator.EQ, "grouped ingredient");

        group = groups[1];
        assert_nonnull (group);
        assert_nonnull (group.title);
        assert_cmpstr (group.title, CompareOperator.EQ, "Group 1");
        assert_nonnull (group.ingredients);
        assert_cmpint (group.ingredients.size, CompareOperator.EQ, 2);

        // - *1 ⅕* [link ingredient](./ingredients.md)
        ing = group.ingredients[0];
        assert_nonnull (ing);
        assert_nonnull (ing.amount);
        assert_cmpfloat (ing.amount.value, CompareOperator.EQ, 1.2);
        assert_null (ing.amount.unit);
        assert_cmpstr (ing.name, CompareOperator.EQ, "link ingredient");
        assert_cmpstr (ing.link, CompareOperator.EQ, "./ingredients.md");

        // - unit is optional
        ing = group.ingredients[1];
        assert_nonnull (ing);
        assert_null (ing.amount);
        assert_cmpstr (ing.name, CompareOperator.EQ, "unit is optional");

        group = groups[2];
        assert_nonnull (group);
        assert_nonnull (group.title);
        assert_cmpstr (group.title, CompareOperator.EQ, "Subgroup 1.1");
        assert_nonnull (group.ingredients);
        assert_cmpint (group.ingredients.size, CompareOperator.EQ, 1);

        // - *1.25 ml* ingredient
        ing = group.ingredients[0];
        assert_nonnull (ing);
        assert_nonnull (ing.amount);
        assert_cmpfloat (ing.amount.value, CompareOperator.EQ, 1.25);
        assert_nonnull (ing.amount.unit);
        assert_cmpstr (ing.amount.unit.name, CompareOperator.EQ, "ml");
        assert_cmpstr (ing.name, CompareOperator.EQ, "ingredient");

        group = groups[3];
        assert_nonnull (group);
        assert_nonnull (group.title);
        assert_cmpstr (group.title, CompareOperator.EQ, "Group 2");
        assert_nonnull (group.ingredients);
        assert_cmpint (group.ingredients.size, CompareOperator.EQ, 2);

        // - text isn't optional
        ing = group.ingredients[0];
        assert_nonnull (ing);
        assert_null (ing.amount);
        assert_cmpstr (ing.name, CompareOperator.EQ, "text isn't optional");

        // - *hey* amount is valid without factor
        ing = group.ingredients[1];
        assert_nonnull (ing);
        assert_nonnull (ing.amount);
        assert_nonnull (ing.amount.unit);
        assert_cmpstr (ing.amount.unit.name, CompareOperator.EQ, "hey");
        assert_cmpstr (ing.name, CompareOperator.EQ, "amount is valid without factor");

        var instructions = actual.instructions;
        assert_nonnull (instructions);
        assert_cmpstr (instructions, CompareOperator.EQ, "Instructions are very instructive.");
    }

}
