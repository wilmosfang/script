#!/bin/bash
#
#used to convert ``` to jekyll code block format
##

perl -i.bak  -p -e 'BEGIN{$flag=2}  if (/^\`\`\`/ and $flag == 2) {s/^\`\`\`/{% highlight bash %}/ ; $flag=3 } ; if (/^\`\`\`/ and $flag == 3) {s/^\`\`\`/{% endhighlight %}/ ; $flag=2 }'  $1
