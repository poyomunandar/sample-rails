import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class Webpack {

	String fileSeparator = "/";
	String operatingSystem = "linux";

	public Webpack() {
		String OS = System.getProperty("os.name").toLowerCase();
		if (OS.indexOf("win") >= 0) {
			fileSeparator = "\\";
			operatingSystem = "windows";
		}
	}

	public void modifySourceCode(String root, String webpackCommandPath) {
		String base = fileSeparator;
		if (operatingSystem.equals("windows"))
			base = root.replaceAll("/", "\\");
		String data = "module.exports = [{\n     entry: [";
		String files = "";
		String indexes = "";
		List<String> jsIncluded = getJsFileNeedToPackPerFolder(root);
		boolean firstTime = true;
		
		// start recursive
		Object[] result = processDirectory(fileSeparator + "www" + fileSeparator + "components"
				, data, files, indexes, base, firstTime, jsIncluded);
		files = (String)result[0];
		data = (String)result[1];
		indexes = (String)result[2];
		// end recursieve
		
//		File folder = new File(base + fileSeparator + "www" + fileSeparator + "components");
//		File[] listOfFiles = folder.listFiles();
//		for (int i = 0; i < listOfFiles.length; i++) {
//			String directory = listOfFiles[i].getName();
//			if (directory.equals(".") || directory.equals("..") || listOfFiles[i].isFile())
//				continue;
//			boolean data_exist = false;
//			File folder2 = new File(
//					base + fileSeparator + "www" + fileSeparator + "components" + fileSeparator + directory);
//			File[] listOfFiles2 = folder2.listFiles();
//			int index_header = 0;
//			for (int j = 0; j < listOfFiles2.length; j++) {
//				String filename = listOfFiles2[j].getName();
//				if (!jsIncluded.contains("<script src=\"components" + "/" + directory + "/" + filename + "\"></script>")
//						|| filename.equals(".") || filename.equals("..") || !filename.contains(".js")
//						|| listOfFiles2[j].isDirectory())
//					continue;
//				if (index_header == 0 && !firstTime)
//					data += ",\n{\n     entry: [";
//				index_header += 1;
//				firstTime = false;
//				data_exist = true;
//				data += "'./www/components/" + directory + "/" + filename + "',\n";
//				files += base + fileSeparator + "www" + fileSeparator + "components" + fileSeparator + directory
//						+ fileSeparator + filename + "\n";
//			}
//			if (data_exist) {
//				data = data.substring(0, data.length() - 2);
//				data += "  ],\n     output: {\n         path: './www/components/" + directory
//						+ "',\n         filename: '" + directory + ".main.js'\n     }\n}";
//				indexes += "<script src=\"components" + "/" + directory + "/" + directory + ".main.js\"></script>\n";
//			}
//			File folder3 = new File(
//					base + fileSeparator + "www" + fileSeparator + "components" + fileSeparator + directory);
//			File[] listOfFiles3 = folder3.listFiles();
//			for (int k = 0; k < listOfFiles3.length; k++) {
//				String subdirectory = listOfFiles3[k].getName();
//				data_exist = false;
//				if (subdirectory.equals(".") || subdirectory.equals("..") || listOfFiles3[k].isFile())
//					continue;
//				File folder4 = new File(base + fileSeparator + "www" + fileSeparator + "components" + fileSeparator
//						+ directory + fileSeparator + subdirectory);
//				File[] listOfFiles4 = folder4.listFiles();
//				index_header = 0;
//				for (int index = 0; index < listOfFiles4.length; index++) {
//					String filename = listOfFiles4[index].getName();
//					if (!jsIncluded.contains("<script src=\"components" + "/" + directory + "/" + subdirectory + "/"
//							+ filename + "\"></script>") || filename.equals(".") || filename.equals("..")
//							|| !filename.contains(".js") || listOfFiles4[index].isDirectory())
//						continue;
//					if (index_header == 0 && !firstTime)
//						data += ",\n{\n     entry: [";
//					index_header += 1;
//					firstTime = false;
//					data_exist = true;
//					data += "'./www/components/" + directory + "/" + subdirectory + "/" + filename + "',\n";
//					files += base + fileSeparator + "www" + fileSeparator + "components" + fileSeparator + directory
//							+ fileSeparator + subdirectory + fileSeparator + filename + "\n";
//				}
//				if (data_exist) {
//					data = data.substring(0, data.length() - 2);
//					data += "  ],\n     output: {\n         path: './www/components/" + directory + "/" + subdirectory
//							+ "',\n         filename: '" + directory + "." + subdirectory + ".js'\n     }\n}";
//					indexes += "<script src=\"components" + "/" + directory + "/" + subdirectory + "/" + directory + "."
//							+ subdirectory + ".js\"></script>\n";
//				}
//				File folder5 = new File(base + fileSeparator + "www" + fileSeparator + "components" + fileSeparator
//						+ directory + fileSeparator + subdirectory + "");
//				File[] listOfFiles5 = folder5.listFiles();
//				for (int index = 0; index < listOfFiles5.length; index++) {
//					String filename = listOfFiles5[index].getName();
//					if (filename.equals(".") || filename.equals("..") || listOfFiles5[index].isFile())
//						continue;
//					File folder6 = new File(base + fileSeparator + "www" + fileSeparator + "components" + fileSeparator
//							+ directory + fileSeparator + subdirectory + fileSeparator + filename);
//					File[] listOfFiles6 = folder6.listFiles();
//					index_header = 0;
//					data_exist = false;
//					for (int index2 = 0; index2 < listOfFiles6.length; index2++) {
//						String subsubdirectory = listOfFiles6[index2].getName();
//						if (!jsIncluded.contains("<script src=\"components" + "/" + directory + "/" + subdirectory + "/"
//								+ filename + "/" + subsubdirectory + "\"></script>") || subsubdirectory.equals(".")
//								|| subsubdirectory.equals("..") || !subsubdirectory.contains(".js")
//								|| listOfFiles6[index2].isDirectory())
//							continue;
//						if (index_header == 0 && !firstTime)
//							data += ",\n{\n     entry: [";
//						index_header += 1;
//						firstTime = false;
//						data_exist = true;
//						data += "'./www/components/" + directory + "/" + subdirectory + "/" + filename + "/"
//								+ subsubdirectory + "',\n";
//						files += base + fileSeparator + "www" + fileSeparator + "components" + fileSeparator + directory
//								+ fileSeparator + subdirectory + fileSeparator + filename + fileSeparator
//								+ subsubdirectory + "\n";
//					}
//					if (data_exist) {
//						data = data.substring(0, data.length() - 2);
//						data += "  ],\n     output: {\n         path: './www/components/" + directory + "/"
//								+ subdirectory + "/" + filename + "',\n         filename: '" + subdirectory + "."
//								+ filename + ".js'\n     }\n}";
//						indexes += "<script src=\"components" + "/" + directory + "/" + subdirectory + "/" + filename
//								+ "/" + subdirectory + "." + filename + ".js\"></script>\n";
//					}
//				}
//			}
//		}
		data += "];";

		writeFile(base + fileSeparator + "webpack.config.js", data);
		writeFile(base + fileSeparator + "listtoremove.txt", files);
		runWebpack(base, webpackCommandPath);
		modifyIndexHTML(base, indexes);
		for (String fileToRemove : readFile(base + fileSeparator + "listtoremove.txt"))
			new File(fileToRemove).delete();
		new File(base + fileSeparator + "webpack.config.js").delete();
		new File(base + fileSeparator + "listtoremove.txt").delete();
	}

	public Object[] processDirectory(String path, String data, String files, String indexes, String base, boolean firstTime, List<String> jsIncluded){
		// path = fileSeparator + "www" + fileSeparator + "components"
		String prefix1 = path.replaceAll(fileSeparator,"/");
		String prefix2 = "";
		String[] splittedMessage = path.split(fileSeparator);
		for(int i=0; i < splittedMessage.length; i++){
			if(i == 0)
				continue;
			prefix2 = splittedMessage[i] + "/";
		}
		File folder = new File(base  + path);
		File[] listOfFiles = folder.listFiles();
		for (int i = 0; i < listOfFiles.length; i++) {
			String directory = listOfFiles[i].getName();
			if (directory.equals(".") || directory.equals("..") || listOfFiles[i].isFile())
				continue;
			boolean data_exist = false;
			File folder2 = new File(base  + path + fileSeparator + directory);
			File[] listOfFiles2 = folder2.listFiles();
			int index_header = 0;
			for (int j = 0; j < listOfFiles2.length; j++) {
				String filename = listOfFiles2[j].getName();
				if (!jsIncluded.contains("<script src=\"" + prefix2 + directory + "/"  + filename + "\"></script>") || filename.equals(".") || filename.equals("..") || !filename.contains(".js") || listOfFiles2[j].isDirectory())
					continue;
				if (index_header == 0 && !firstTime)
					data += ",\n{\n     entry: [";
				index_header += 1;
				firstTime = false;
				data_exist = true;
				data += "'." + prefix1 + "/" + directory + "/" + filename + "',\n";
				files += base  + path + fileSeparator + directory + fileSeparator + filename + "\n";
			}
			if (data_exist) {
				data = data.substring(0, data.length() - 2);
				data += "  ],\n     output: {\n         path: '." + prefix1 + "/" + directory + "',\n         filename: '" + directory + ".main.js'\n     }\n}";
				indexes += "<script src=\"" + prefix2 + directory + "/" + directory + ".main.js\"></script>\n";
			}
			Object[] result = processDirectory(path + fileSeparator + directory, data, files, indexes, base, firstTime, jsIncluded);
			files = (String)result[0];
			data = (String)result[1];
			indexes = (String)result[2];
			firstTime = (boolean) result[3];
			path = (String) result[4];
		}
		return new Object[] {files, data, indexes, firstTime, path};
	}

	public void writeFile(String path, String data) {
		BufferedWriter bw = null;
		FileWriter fw = null;
		try {
			fw = new FileWriter(path);
			bw = new BufferedWriter(fw);
			bw.write(data);
		} catch (IOException e) {
			e.printStackTrace();
		} finally {
			try {
				if (bw != null)
					bw.close();
				if (fw != null)
					fw.close();
			} catch (IOException ex) {
				ex.printStackTrace();
			}
		}
	}

	public List<String> readFile(String path) {
		FileReader fr = null;
		BufferedReader br = null;
		List<String> result = new ArrayList<String>();
		try {
			fr = new FileReader(path);
			br = new BufferedReader(fr);
			while (br.ready()) {
				String line = br.readLine();
				result.add(line);
			}
		} catch (Exception e) {
			e.printStackTrace();
		} finally {
			try {
				if (br != null)
					br.close();
				if (fr != null)
					fr.close();
			} catch (IOException ex) {
				ex.printStackTrace();
			}

		}
		return result;
	}

	public void runWebpack(String base, String webpackCommandPath) {
		try {
			Runtime.getRuntime().exec(new String[] { webpackCommandPath }, null, new File(base));
			Thread.sleep(20000);
		} catch (Exception e) {
			e.printStackTrace();
		}
	}

	public List<String> getJsFileNeedToPackPerFolder(String base) {
		List<String> files = readFile(base + fileSeparator + "www" + fileSeparator + "index.html");
		List<String> indexFiles = new ArrayList<String>();
		for (String line : files)
			if (line.contains("<script src=\"components"))
				indexFiles.add(line.trim());
		Collections.sort(indexFiles);
		return indexFiles;
	}

	public void modifyIndexHTML(String base, String dataToOverwrite) {
		String newFilesToWrite = "";
		List<String> files = readFile(base + fileSeparator + "www" + fileSeparator + "index.html");
		for (String line : files) {
			if (line.contains("<script src=\"components"))
				continue;
			if (line.contains("</body>"))
				newFilesToWrite += dataToOverwrite + "\r\n";
			newFilesToWrite += line + "\r\n";
		}
		writeFile(base + fileSeparator + "www" + fileSeparator + "index.html", newFilesToWrite);
	}

	public static void main(String args[]) {
		new Webpack().modifySourceCode(args[0], args[1]);
	}
	
}
