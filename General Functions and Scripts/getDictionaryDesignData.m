function entryValue=getDictionaryDesignData(EntryName)
myDictionaryObj = Simulink.data.dictionary.open('Dictionary.sldd');
dDataSectObj = getSection(myDictionaryObj,'Design Data');
entryValue=getValue(getEntry(dDataSectObj,EntryName));