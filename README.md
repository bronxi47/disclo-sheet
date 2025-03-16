# Disclo-sheet

**Disclo-sheet** is a Bash script that, given a list of URLs, filters XLS and XLSX files, downloads them, takes a screenshot, and creates an `index.html` file. This allows you to quickly visualize each screenshot at a glance and understand its content. It speeds up the process of searching for sensitive information in XLS(X) files.

## 🚀 How to Use  

1. **Give execution permissions to the script:**  
```
chmod +x disclo-sheet.sh
```
   
2. **Run the script with a list of URLs:**  
```
./disclo-sheet.sh urls_list.txt
```

3. **The script will create a folder containing:**
- The downloaded XLS/XLSX files.
- Screenshots of each file.
- An index.html file for easy visualization.

### Simply open the index.html file in yoRun the script with a list of URLs:
```
./disclo-sheet.sh urls_list.txt
```
    
### The script will create a folder containing:
- The downloaded XLS/XLSX files.
- Screenshots of each file.
- An index.html file for easy visualization.

Simply open the index.html file in your browser to review the screenshots and quickly identify potential sensitive information.

### 🛠 Requirements
1. **wget** for downloading files.
2. **libreoffice** or soffice for rendering XLS/XLSX files.
3. **convert** for taking screenshots.
