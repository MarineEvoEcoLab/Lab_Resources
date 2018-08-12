# Re-suspending Lyophilized Oligonucleotides

Synthetic oligonucleotides are usually shipped from the vendors in lyophilized form meaning the DNA solution has been freeze-dried to remove all liquid, leaving the oligo as a dry residue in the bottom of the tube.  The oligo must be re-suspended in liquid before it can be used as a primer in PCR, or for other molecular biology applications.  

## Buffer Choice
Oligos could be re-suspended in simply molecular grade water, but usually some sort of storage buffer is preferred. TE buffer (10mM Tris, 1mM EDTA, pH 8.0) is recommended for long term storage.  Like any other DNA, oligonucleotides are more stable in TE because the pH is kept slightly alkaline by the Tris, preventing autocatalytic depurination that can occur under acidic conditions.  Additionally the EDTA chelates divalent cations required for activity by most nucleases, affording some protection from contaminating nucleases that may be present.  

However, the EDTA in TE can be problematic in downstream enzymatic reactions.  For example, EDTA may interfere with their PCR by chelating the Mg++ required for activity of the DNA polymerase.  As a compramise, you can use “low TE” instead of TE.  Low TE is the same as TE except the EDTA concentration is tenfold less (0.1 mM).  Therefore the EDTA introduced to your downstream reactions will amount to no more than 0.01mM, which is entirely negligible.  I think the choice can depend on how much of the nucleotides you have to resuspend.  If you can easily create a 500 µM stock, TE will be just fine, but if you need to use a more dilute stock between 100-200 µM, it's recommended to use low TE.

## How much liquid to add?

For many reactions, the oligos are typically drawn from a working solution of 10 µM.  However it is not recommended to initially re-suspend the entire primer stock to this concentration for two reasons.  First, what if you want to try a new protocol that requires a working solution of 50 µM?  The effort necessary to concentrate and re-quantify the solution would not be trivial.  More importantly, DNA is more stable at higher concentrations, so for long-term storage a concentration of 200 – 500 µM is recommended.  From this stock solution you can prepare aliquots of working solution at the desired lower concentration as needed.

The calculation of how much liquid to add goes as follows: 

µL TE = (nanomoles DNA) / (desired conc. in µM) * 1000

The nanomoles DNA present in the tube is listed on the data sheet that ships with the oligo and may also be printed on the tube label (look for “nMoles”).  Labeled primers from ABI may be given in picomoles (“pMoles”) in which case you divide by 1000 to get the nanomoles (e.g. 10,000 picomoles = 10 nmoles).  

*For a shortcut calculation, just multiply the nMoles number by 5 to get the volume in µL of TE (or low TE) to add to yield a 200µM stock solution.  For a 500µM stock solution multiply by 2.*

## Protocol
* Wipe down the NGS library bench with RNase-Away, and wear clean gloves
* Centrifuge the tubes of lyophilized DNA in a tabletop centrifuge for one minute
  * This will ensure that any dried DNA that may have broken loose during shipping is forced to the bottom of the tube.
* Add the calculated amount of TE or low TE using **DNA library prep pippettes and barrier pipette tips.**  
* Once the liquid has been added, cap the tube and vortex for about 15 seconds, then write the final concentration directly on the tube with a black Sharpie (other people may eventually use the oligos, and they will need to know the concentration)

When re-suspending oligonucleotides work at the PCR bench, wipe it down with RNase-Away, and wear clean gloves.  First centrifuge the tubes of lyophilized DNA in a tabletop centrifuge for one minute.  This will ensure that any dried DNA that may have broken loose during shipping is forced to the bottom of the tube.  Then add the calculated amount of TE or low TE using **DNA library prep pippettes and barrier pipette tips.**  

## Additional information
Store your stock solutions and working solutions at –20°C when not in use, i.e. when you don’t plan to use them again today or tomorrow.  Also, make enough working solution to last for a while.  You shouldn’t be diluting a new aliquot of working solution every time you do a PCR.  The idea is to minimize thawing and re-freezing of the stock solution, since repeated freeze/thaw cycles may eventually degrade the DNA.  For example, if you have 100 µL of 200 µM working stock you might freeze/thaw it 20 times to make 20 aliquots of working solution at 1 mL each.  Each of those 20 aliquots might themselves be frozen and thawed another ten times for PCR setup, but even the last aliquot will only experience 30 freeze/thaw cycles, whereas if you made a new dilution every time you ran a PCR (please don't) the last aliquot would have experienced 200 freeze/thaw cycles.

Note: If you are still having problems there are calculators available at the IDT website to compute resuspension volumes for lyophilized oligos and dilution volumes for working stock preparation.  At the time of this writing the URLs are:
[http://www.idtdna.com/analyzer/Applications/resuspensioncalc/Default.aspx/](http://www.idtdna.com/analyzer/Applications/resuspensioncalc/Default.aspx/)
[http://www.idtdna.com/analyzer/Applications/DilutionCalc/Default.aspx/](http://www.idtdna.com/analyzer/Applications/DilutionCalc/Default.aspx/)
