﻿
Util_VersionCompare(other,local) {
	ver_other:=StrSplit(other,".")
	ver_local:=StrSplit(local,".")
	for _index, _num in ver_local
		if ( (ver_other[_index]+0) > (_num+0) )
			return 1
		else if ( (ver_other[_index]+0) < (_num+0) )
			return 0
	return 0
}

;Rename this Function. I don't have a good name for it now...
Util_CSV2TagsObj(rawCSV:="") {
	obj:=Object()
	Loop, Parse, rawCSV, CSV
		if ( (k:=Trim(A_LoopField)) != "")
			obj.Insert(k)
	return obj
}

Util_TagsObj2CSV(TagsObj:="") {
	if !IsObject(TagsObj)
		return ""
	CSV:=""
	for index, tag in TagsObj
		if ( (k:=Trim(tag)) != "")
			CSV := CSV k ","
	return SubStr(CSV,1,-1)
}

Util_SingleArray2Str(Arr,Delimiter:="",before:=0) {
	s:=""
	if (before) {
		for each, item in Arr
			s.= Delimiter item
	} else {
		for each, item in Arr
			s.= item Delimiter
		s:=SubStr(s,1,(-1*Abs(StrLen(Delimiter))))
	}
	return s
}

Util_ArrayInsert(ByRef Arr,InsArr) {
	for each, item in InsArr
		Arr.Insert(item)
	return Arr
}

Util_ObjCount(Obj) {
	if (!IsObject(Obj))
		return 0
	z:=0
	for k in Obj
		z+=1 ;or z:=A_Index
	return z
}

Util_ArraySort(Arr) { ;AutoSort
	t:=Object()
	for k, v in Arr
		t[RegExReplace(v,"\s")]:=v
	for k, v in t
		Arr[A_Index]:=v
	return Arr
}

Util_ShortPath(p,l=50) {
	VarSetCapacity(_p, (A_IsUnicode?2:1)*StrLen(p) )
	DllCall("shlwapi\PathCompactPathEx"
		,"str", _p
		,"str", p
		,"uint", abs(l)
		,"uint", 0)
	return _p
}

Util_TempDir(outDir="")
{
	Loop
		tempName := "~temp" A_TickCount ".tmp", tempDir := ((!outDir)?A_Temp:outDir) "\" tempName
	until !FileExist(tempDir)
	return tempDir
}

Util_TempFile()
{
	Loop
		tempName := A_Temp "\~temp" A_TickCount ".tmp"
	until !FileExist(tempName)
	return tempName
}

Util_FileAlign(f)
{
	while f.Pos & 3
		f.WriteUChar(0)
}

Util_FileWriteStr(f, ByRef str)
{
	pos := f.Pos
	f.WriteUInt(0)
	f.Write(str)
	size := (tmp := f.Pos) - pos - 4
	f.Pos := pos
	f.WriteUInt(size)
	f.Pos := tmp
	Util_FileAlign(f)
}

Util_ReadLenStr(ptr, ByRef endPtr)
{
	len := NumGet(ptr+0, "UInt")
	endPtr := ptr + ((len+7)&~3)
	return StrGet(ptr+4, len, "UTF-8")
}

Util_DirTree(dir)
{
	data := [], ldir := StrLen(dir)+1
	Loop, %dir%\*.*, 1
	{
		StringTrimLeft, name, A_LoopFileFullPath, %ldir%
		e := { name: name, fullPath: A_LoopFileLongPath }
		if SubStr(name, 0) = "~" || SubStr(name, -3) = ".bak" || name = "package.json" || name = ".aspdm_ignore"
			continue
		IfInString, A_LoopFileAttrib, D
		{
			e.isDir := true
			e.contents := Util_DirTree(A_LoopFileFullPath)
		}
		data.Insert(e)
	}
	return data
}

Util_DirTreeIgnore(tree,patterns)
{
	if (patterns.MaxIndex == 0)
		return tree
	for i, file in tree
	{
		for j, pat in patterns
		{
			if RegExMatch(file.fullPath,pat) {
				tree.Remove(i)
				break
			}
		}
		if (tree.HasKey(i)) {
			if (file.isDir)
				tree[i].contents:=Util_DirTreeIgnore(file.contents,patterns)
			else
				continue
		}
	}
	return tree
}

Util_isASCII(s)
{
	Loop, Parse, s
	{
		z:=Asc(A_LoopField)
		;if ( (z<=8) || (z==11) || (z==12) || (z==127) || ((z>=14) && (z<=31)) )
		if ( z==0x09 || z==0x0A || z==0x0D || (0x20 <= z && z <= 0x7E) )
			continue
		else
			return 0
	}
	return 1
}
