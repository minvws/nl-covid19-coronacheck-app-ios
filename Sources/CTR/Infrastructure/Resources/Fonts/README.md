Note on Fonts: 

At time of writing:
- Fonts aren't loaded properly from a SPM package
- We want resources (fonts, asset libs, .strings etc) to be in Shared SPM
- R.swift runs from/on the Shared SPM, so the font appears in the R.generated.swift
- At runtime iOS doesn't find the font, so we need two copies of the fonts, unfortunately. One in the main target, and one in Shared. 
  - The one in Shared is used for R.swift, the other is actually loaded at runtime.