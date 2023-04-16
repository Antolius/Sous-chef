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

**5 cups, 20 ml, 5.5 Tassen**

---

- *5* ungrouped ingredient
- *5.2 ml* grouped ingredient

## Group 1

- *1* [link ingredient](./ingredients.md)
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
        assert (actual != null);
        assert_cmpstr (actual.title, CompareOperator.EQ, "Title");
        assert_cmpstr (actual.description, CompareOperator.EQ, """The description describes this recipe. It is delicious!

It can have multiple lines an may even include pictures.

<img src="../logo/recipemd-mark.svg" />""");
    }

}
