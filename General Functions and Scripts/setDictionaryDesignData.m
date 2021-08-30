function setDictionaryDesignData(EntryName,EntryValue)
myDictionaryObj = Simulink.data.dictionary.open('Dictionary.sldd');
dDataSectObj = getSection(myDictionaryObj,'Design Data');
addEntry(dDataSectObj,EntryName,EntryValue);
myDictionaryObj.saveChanges();