while(flagsLoop)
{
  ...
  if(flagsIf) break;
  ...
}while(flagsLoop); // BAD: when exiting through `break`, it is possible to get into an eternal loop.
...
while(flagsLoop)
{
  ...
  if(flagsIf) break;
  ...
} // GOOD: correct cycle
...
if(intA+intB) return 1; // BAD: possibly no comparison
...
if(intA+intB>intC) return 1; // GOOD: correct comparison
