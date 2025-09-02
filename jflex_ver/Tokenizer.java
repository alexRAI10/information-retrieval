
/* 
 Simple program to read, write, and tokenize strings found in html files using Jflex
 To tokenize a single file compile and run:
    jflex lexer.jflex
    javac Tokenizer.java Lexer.java
    java Tokenizer <input_file> <output_file>
 To tokenize multiple files run bash script
    ./jflex-tokenizer.sh
*/

import java.io.BufferedWriter;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.io.Reader;
import java.io.Writer;


public class Tokenizer {
    public static void main(String[] args) {

        //Timer set to measure execution
        // System.out.println("\n -> Program running... \n");
        // long startTime = System.nanoTime();

        //Setting the read/write files
        String InFilename, OutFilename;

        if (args.length != 2) {
            System.err.println("Not the right number of arguments.");
            System.exit(1);
        } 

        InFilename = args[0];
        OutFilename = args[1];
        
        //Added the .html extension in case no .html extension was added as args
        if (!InFilename.endsWith(".html")) {
            InFilename = args[0] + ".html";
        }

        //Added the .txt extension in case no .txt extension was added as args
        if (!OutFilename.endsWith(".txt")) {
            OutFilename = args[1] + ".txt";
        }

        System.out.println("The input filename is: " + InFilename);
        System.out.println("The output filename is: " + OutFilename);

        try {


            Reader din = new FileReader(InFilename);
            Writer dout = new BufferedWriter(new FileWriter(OutFilename));
            

                System.out.println("Opened " + InFilename + " for reading");
                System.out.println("Opened " + OutFilename + " for writing");

                //Process the html text using lexer
                Lexer lex = new Lexer(din);
                String token;
                while ((token = lex.yylex()) != null ) {
                    dout.write(token);
                    dout.write("\n");
                }
                dout.flush();
            } catch (IOException e) {
                System.err.println("Could not open ouput file: " + OutFilename);
                System.exit(2);
        }
    }
}

        
    
    //Calculates the time in microseconds
    // long endTime = System.nanoTime();
    // long executionTime = (endTime - startTime) / 1000000;
    // System.out.println("\n -> Execution time: " + executionTime + "ms");
