/*
Authors: Alain Delgado, Micah McCollum
Code used as base for CSCE 45503.
Simple program to read, write, and tokenize strings found in html files using JSoup.
*/
import java.io.BufferedWriter;
import java.io.FileWriter;
import java.io.IOException;
import java.io.File;
import org.jsoup.Jsoup;
import org.jsoup.nodes.Document;

public class Tokenizer {
    public static void main(String[] args) {
        // Timer set to measure execution
        // System.out.println("\n -> Program running... \n");
        // long startTime = System.nanoTime();

        //Setting the read/write files
        String inFilename, outFilename;
        BufferedWriter dout = null;

        if (args.length != 2) {
            System.err.println("Not the right number of arguments.");
            System.exit(1);
        }
        else {
            inFilename = args[0];
            outFilename = args[1];

            //Added the .html extension in case no .html extension was added as args
            if (!inFilename.endsWith(".html")) {
                inFilename += ".html";
            }

            //Added the .txt extension in case no .txt extension was added as args
            if (!outFilename.endsWith(".txt")) {
                outFilename += ".txt";
            }

            System.out.println("The input filename is: " + inFilename);
            System.out.println("The output filename is: " + outFilename);

            try {

                // Try/catch error in case output file not found
                dout = new BufferedWriter(new FileWriter(outFilename));

                System.out.println("Opened " + inFilename + " for reading");
                System.out.println("Opened " + outFilename + " for writing");

                // Process the html text using JSoup
                File html = new File(inFilename);
                Document doc = Jsoup.parse(html, "UTF-8");
                String textContent = doc.text();

                // Split
                String[] tokens = textContent.split("\\W+");
                for (String token : tokens) {
                    if (!token.isEmpty()) {
                        dout.write(token);
                        dout.newLine();
                    }
                }

                // Close file writer
                dout.close();
            }
            catch (IOException e) {
                System.err.println("Could not open output file: " + outFilename);
            }
        }    
        //Calculates the time in microseconds
        // long endTime = System.nanoTime();
        // long executionTime = (endTime - startTime) / 1000000;
        // System.out.println("\n -> Execution time: " + executionTime + "ms");
    }
}