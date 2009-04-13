#!/usr/bin/env python
# -*- coding: utf-8 -*-
# NAMESPACEにある関数名をlispで使えるように変換させます。

import re

mer = []
f = open("D:\Rscript\ess\NAMESPACE")
for line in f:
    line = line.strip()
    mer.append(line)
f.close()

out = "".join(mer)
out = re.sub(" ","",out)
out = re.sub('\"',"",out)
out = re.sub(",","\" \"",out)
out = re.sub("^""",'\"',out)
out = re.sub("$""",'\"',out)