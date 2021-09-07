function setDictionaryDesignData(EntryName,EntryValue)
myDictionaryObj = Simulink.data.dictionary.open('Dictionary.sldd');
dDataSectObj = getSection(myDictionaryObj,'Design Data');
e=getEntry(dDataSectObj,EntryName);
setValue(e,EntryValue);
myDictionaryObj.saveChanges();