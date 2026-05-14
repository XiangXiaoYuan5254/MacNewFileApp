#!/bin/zsh
set -euo pipefail

SERVICE_DIR="$HOME/Library/Services/新建文件.workflow"
NO_INPUT_SERVICE_DIR="$HOME/Library/Services/新建文件到当前文件夹.workflow"
RESOURCES_DIR="$SERVICE_DIR/Contents/Resources"
NO_INPUT_RESOURCES_DIR="$NO_INPUT_SERVICE_DIR/Contents/Resources"

rm -rf "$SERVICE_DIR"
rm -rf "$NO_INPUT_SERVICE_DIR"
mkdir -p "$RESOURCES_DIR"
mkdir -p "$NO_INPUT_RESOURCES_DIR"

cat > "$SERVICE_DIR/Contents/Info.plist" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>CFBundleDevelopmentRegion</key>
	<string>zh_CN</string>
	<key>CFBundleIdentifier</key>
	<string>com.local.services.newfile</string>
	<key>CFBundleName</key>
	<string>新建文件</string>
	<key>CFBundleShortVersionString</key>
	<string>1.0</string>
	<key>NSServices</key>
	<array>
		<dict>
			<key>NSMenuItem</key>
			<dict>
				<key>default</key>
				<string>新建文件...</string>
			</dict>
			<key>NSMessage</key>
			<string>runWorkflowAsService</string>
			<key>NSSendFileTypes</key>
			<array>
				<string>public.item</string>
				<string>public.folder</string>
			</array>
		</dict>
	</array>
</dict>
</plist>
PLIST

cat > "$NO_INPUT_SERVICE_DIR/Contents/Info.plist" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>CFBundleDevelopmentRegion</key>
	<string>zh_CN</string>
	<key>CFBundleIdentifier</key>
	<string>com.local.services.newfile.currentfolder</string>
	<key>CFBundleName</key>
	<string>新建文件到当前文件夹</string>
	<key>CFBundleShortVersionString</key>
	<string>1.0</string>
	<key>NSServices</key>
	<array>
		<dict>
			<key>NSMenuItem</key>
			<dict>
				<key>default</key>
				<string>新建文件到当前文件夹...</string>
			</dict>
			<key>NSMessage</key>
			<string>runWorkflowAsService</string>
		</dict>
	</array>
</dict>
</plist>
PLIST

cat > "$RESOURCES_DIR/document.wflow" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>AMApplicationBuild</key>
	<string>521</string>
	<key>AMApplicationVersion</key>
	<string>2.10</string>
	<key>AMDocumentVersion</key>
	<string>2</string>
	<key>actions</key>
	<array>
		<dict>
			<key>action</key>
			<dict>
				<key>ActionBundlePath</key>
				<string>/System/Library/Automator/Run AppleScript.action</string>
				<key>ActionName</key>
				<string>Run AppleScript</string>
				<key>ActionParameters</key>
				<dict>
					<key>source</key>
					<string>on run {input, parameters}
	set choices to {"文本文档 (.txt)", "Markdown (.md)", "富文本 (.rtf)", "CSV 表格 (.csv)", "JSON (.json)", "HTML (.html)", "JavaScript (.js)", "Python (.py)", "Swift (.swift)", "Shell 脚本 (.sh)"}
	set picked to choose from list choices with title "新建文件" with prompt "选择文件类型" default items {"文本文档 (.txt)"} OK button name "创建" cancel button name "取消"
	if picked is false then return input
	set pickedName to item 1 of picked
	
	set targetFolder to my targetFolderPath(input)
	set templateInfo to my templateForChoice(pickedName)
	set baseName to item 1 of templateInfo
	set fileExt to item 2 of templateInfo
	set fileContents to item 3 of templateInfo
	set shouldChmod to item 4 of templateInfo
	
	set destinationPath to my uniquePath(targetFolder, baseName, fileExt)
	set fileRef to open for access (POSIX file destinationPath) with write permission
	try
		set eof of fileRef to 0
		write fileContents to fileRef as «class utf8»
		close access fileRef
	on error errorMessage
		try
			close access fileRef
		end try
		display alert "创建文件失败" message errorMessage
		return input
	end try
	
	if shouldChmod is true then do shell script "chmod 755 " &amp; quoted form of destinationPath
	tell application "Finder" to reveal POSIX file destinationPath
	return input
end run

on targetFolderPath(input)
	if input is not {} then
		set firstPath to POSIX path of (item 1 of input as alias)
		set kindResult to do shell script "if [ -d " &amp; quoted form of firstPath &amp; " ]; then printf dir; else printf file; fi"
		if kindResult is "dir" then
			return firstPath
		else
			return do shell script "dirname " &amp; quoted form of firstPath
		end if
	end if
	
	tell application "Finder"
		if (count of Finder windows) &gt; 0 then
			return POSIX path of (target of front Finder window as alias)
		else
			return POSIX path of (path to desktop folder)
		end if
	end tell
end targetFolderPath

on templateForChoice(choiceName)
	if choiceName contains ".txt" then return {"新建文本文档", "txt", "", false}
	if choiceName contains ".md" then return {"新建Markdown", "md", "# Untitled" &amp; linefeed, false}
	if choiceName contains ".rtf" then return {"新建富文本", "rtf", "{\\rtf1\\ansi\\deff0\\n}", false}
	if choiceName contains ".csv" then return {"新建CSV", "csv", "name,value" &amp; linefeed, false}
	if choiceName contains ".json" then return {"新建JSON", "json", "{" &amp; linefeed &amp; "  " &amp; linefeed &amp; "}" &amp; linefeed, false}
	if choiceName contains ".html" then return {"新建HTML", "html", "&lt;!doctype html&gt;" &amp; linefeed &amp; "&lt;html lang=\"zh-CN\"&gt;" &amp; linefeed &amp; "&lt;head&gt;" &amp; linefeed &amp; "  &lt;meta charset=\"utf-8\"&gt;" &amp; linefeed &amp; "  &lt;meta name=\"viewport\" content=\"width=device-width, initial-scale=1\"&gt;" &amp; linefeed &amp; "  &lt;title&gt;Untitled&lt;/title&gt;" &amp; linefeed &amp; "&lt;/head&gt;" &amp; linefeed &amp; "&lt;body&gt;" &amp; linefeed &amp; "&lt;/body&gt;" &amp; linefeed &amp; "&lt;/html&gt;" &amp; linefeed, false}
	if choiceName contains ".js" then return {"新建JavaScript", "js", "console.log('Hello');" &amp; linefeed, false}
	if choiceName contains ".py" then return {"新建Python", "py", "#!/usr/bin/env python3" &amp; linefeed &amp; linefeed, true}
	if choiceName contains ".swift" then return {"新建Swift", "swift", "import Foundation" &amp; linefeed &amp; linefeed, false}
	return {"新建Shell脚本", "sh", "#!/bin/zsh" &amp; linefeed &amp; linefeed, true}
end templateForChoice

on uniquePath(folderPath, baseName, fileExt)
	set firstPath to folderPath &amp; "/" &amp; baseName &amp; "." &amp; fileExt
	set existsResult to do shell script "if [ -e " &amp; quoted form of firstPath &amp; " ]; then printf yes; else printf no; fi"
	if existsResult is "no" then return firstPath
	
	repeat with indexValue from 2 to 999
		set candidatePath to folderPath &amp; "/" &amp; baseName &amp; " " &amp; indexValue &amp; "." &amp; fileExt
		set candidateExists to do shell script "if [ -e " &amp; quoted form of candidatePath &amp; " ]; then printf yes; else printf no; fi"
		if candidateExists is "no" then return candidatePath
	end repeat
	
	return folderPath &amp; "/" &amp; baseName &amp; " " &amp; (do shell script "uuidgen") &amp; "." &amp; fileExt
end uniquePath</string>
				</dict>
				<key>AMAccepts</key>
				<dict>
					<key>Container</key>
					<string>List</string>
					<key>Optional</key>
					<true/>
					<key>Types</key>
					<array>
						<string>com.apple.cocoa.path</string>
					</array>
				</dict>
				<key>AMActionVersion</key>
				<string>1.0.2</string>
				<key>AMProvides</key>
				<dict>
					<key>Container</key>
					<string>List</string>
					<key>Types</key>
					<array>
						<string>com.apple.applescript.object</string>
					</array>
				</dict>
				<key>Application</key>
				<array>
					<string>Finder</string>
				</array>
				<key>BundleIdentifier</key>
				<string>com.apple.Automator.RunScript</string>
				<key>CanShowSelectedItemsWhenRun</key>
				<true/>
				<key>CanShowWhenRun</key>
				<true/>
				<key>Category</key>
				<array>
					<string>AMCategoryUtilities</string>
				</array>
				<key>Class Name</key>
				<string>RunScriptAction</string>
				<key>InputUUID</key>
				<string>78C8888C-D73F-4026-B7E5-BB59A3020215</string>
				<key>OutputUUID</key>
				<string>910BFCF1-B533-4F5C-8C16-8F17130B5AEC</string>
				<key>UUID</key>
				<string>1345D291-5C30-4B3C-A22E-5E2FD9EA7D13</string>
			</dict>
		</dict>
	</array>
	<key>connectors</key>
	<dict/>
	<key>state</key>
	<dict/>
	<key>workflowMetaData</key>
	<dict>
		<key>serviceApplicationBundleID</key>
		<string>com.apple.finder</string>
		<key>serviceApplicationPath</key>
		<string>/System/Library/CoreServices/Finder.app</string>
		<key>serviceInputTypeIdentifier</key>
		<string>com.apple.Automator.fileSystemObject</string>
		<key>serviceOutputTypeIdentifier</key>
		<string>com.apple.Automator.nothing</string>
		<key>serviceProcessesInput</key>
		<integer>1</integer>
		<key>workflowTypeIdentifier</key>
		<string>com.apple.Automator.servicesMenu</string>
	</dict>
</dict>
</plist>
PLIST

cp "$RESOURCES_DIR/document.wflow" "$NO_INPUT_RESOURCES_DIR/document.wflow"
/usr/libexec/PlistBuddy -c 'Set :workflowMetaData:serviceInputTypeIdentifier com.apple.Automator.nothing' "$NO_INPUT_RESOURCES_DIR/document.wflow"
/usr/libexec/PlistBuddy -c 'Set :workflowMetaData:serviceProcessesInput 0' "$NO_INPUT_RESOURCES_DIR/document.wflow"

plutil -lint "$SERVICE_DIR/Contents/Info.plist" "$RESOURCES_DIR/document.wflow" "$NO_INPUT_SERVICE_DIR/Contents/Info.plist" "$NO_INPUT_RESOURCES_DIR/document.wflow" >/dev/null
/System/Library/CoreServices/pbs -flush 2>/dev/null || true
killall Finder 2>/dev/null || true

echo "$SERVICE_DIR"
echo "$NO_INPUT_SERVICE_DIR"
