# mPath
Matlab data path scheme inspired by XPath and JSONPath.

### Intro
Identify Matlab variables by their location in an array or structure, not
just by their value.  The intuition is similar to a reference or a handle
object.

But Matlab doesn't provide explicit references, and wrapping data inside a 
handle is only an option when defining your own data.  What happens when
we are working with an existing data model that doesn't use handles?

mPath defines a way of representing the "path" from a given variable, down
through various fields and elements nested within the variable.  It also
provides utilites that operate on paths, for getting and setting the value
at the end of the path.

For now, mPath is part of the mexximp project.  That's where mPath came 
from.  But mPath doesn't depend on the rest of mexximp, and it could be 
broken out into its own project.

### Simple Example
Here's a quick example.  Start with the struct `s` which contains values
nested at different levels, by field and by array index:
```
s.foo = 'bar';
s.baz(1).quack = 42;
s.baz(2).quack = exp(i*pi);
s.baz(3).quack = -999999999;
s.baz(4).quack = 0;
```

With mPath, we can express things like "the value of the "quack" field of 
the second element of the "baz" field of `s`.  The path is a cell array and 
it looks like this:
```
p = {'baz', 2, 'quack'};
```

Actually, it doesn't have to be `s`.  The path is independent of the 
variable it's applied to.  This makes mPath useful for defining data 
mappings and schemas:  You can discover the paths in existing variables, 
and you can express paths that don't yet exist in a variable.

We can get the value at a path:
```
value = mPathGet(s, p)
value =
    42
```

And we can set the value at a path:
```
s = mPathSet(s, p, 43);
s.baz(2).quack
ans = 
    43
```

### Query Example
Inspired by XPath and JSONPath, mPath can also express queries.

An mPath query iterates the elements of an array, applies a sub-path and a
criterion function to each element of the array, and picks the element with
the maximum criterion value.  It returns the path to this winning element.

Here's an example.  We want to know which element of the "baz" field of `s` 
has the greatest absolute value under its "quack" field.  The path looks 
like this:
```
q = {'baz', {'quack', @abs}};
```

Let's unpack this:
 * `q{1}` says to look in the "baz" field.
 * `q{2}` is a cell array, which means do a query over array elements.
 * `q{2}{1}` says for each element, get the value of the "quack" field.
 * `q{2}{2}` says pass each value to the @abs function.

Finally, we collect all the values returned from @abs and find the index of 
the first maximum.  We use this to return a path that answers our query:
```
p2 = mPathQuery(s, q)
p2 = 
    'baz'   [3]
```

So, it was the 3rd element of the "baz" array that had the highest absolute
value of "quack".

What if we want to know the winning value itself?  We can include the query
in a larger path and find out:
```
q = {'baz', {'quack', @abs}, 'quack'};
value = mPathGet(s, q)
value =
    -999999999
```

### Look-around Query.
In the query example above, we focused on "quack".  Let's make things a 
little more complicated and ask about two fields, "quack" and "zoom":
```
s.foo = 'bar';
s.baz(1).quack = 42;
s.baz(1).zoom = 'forty-two';
s.baz(2).quack = exp(i*pi);
s.baz(2).zoom = 'Half of Euler''s identity';
s.baz(3).quack = -999999999;
s.baz(3).zoom = 'negative ninety-ninety-ninety...';
s.baz(4).quack = 0;
s.baz(4).zoom = 'zero';
```

Now we want to pick out a "zoom" value, by "looking around" at 
corresponding "quack" values.  This gets harder to say in English:

>> What is the value of the "zoom" field, 
>> of the ith element of the "baz" field, 
>> where i is the index of the element of the "baz" field, 
>> whose "quack" field has the greatest absolute value?

Yuck!  And yet, this is a fair and useful type of question to ask.  
Fortunately, the query path is not so cumbersome, and very similar to the
query path we've already seen:
```
q = {'baz', {'quack', @abs}, 'zoom'};
value = mPathGet(s, q)
value =
negative ninety-ninety-ninety...
```

[Not that bad!](https://www.youtube.com/watch?v=UtVJdPfm0F8)
