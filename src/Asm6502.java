import java.io.IOException;
import java.io.FileNotFoundException;
import java.io.File;
import java.util.ArrayList;
import java.util.Map;
import java.util.Scanner;
import java.io.FileOutputStream;
import java.util.HashMap;
import java.util.regex.Pattern;
import java.util.regex.Matcher;

public class Asm6502 {

    // Program Counter
    static int START=4096, PC = START;
    static boolean ERROR = false;
    // Assembled program.
    static ArrayList<Byte> asm = new ArrayList<>();

    // Some helpful regexes...
    static String lblOpRegex = "^\\s*(?:(\\w+)\\s*:)?\\s*((?i)DCB|DCW|DSB|DSW|TXT|OPS)(.*)$";

    // Opcode Table
    static Object[][] Opcodes = {
        /* Name, Imm,  ZP,   ZPX,  ZPY,  ABS, ABSX, ABSY,  IND, INDX, INDY, SNGL, BRA */
        {"ADC", 0x69, 0x65, 0x75, null, 0x6d, 0x7d, 0x79, null, 0x61, 0x71, null, null},
        {"AND", 0x29, 0x25, 0x35, null, 0x2d, 0x3d, 0x39, null, 0x21, 0x31, null, null},
        {"ASL", null, 0x06, 0x16, null, 0x0e, 0x1e, null, null, null, null, 0x0a, null},
        {"BIT", null, 0x24, null, null, 0x2c, null, null, null, null, null, null, null},
        {"BPL", null, null, null, null, null, null, null, null, null, null, null, 0x10},
        {"BMI", null, null, null, null, null, null, null, null, null, null, null, 0x30},
        {"BVC", null, null, null, null, null, null, null, null, null, null, null, 0x50},
        {"BVS", null, null, null, null, null, null, null, null, null, null, null, 0x70},
        {"BCC", null, null, null, null, null, null, null, null, null, null, null, 0x90},
        {"BCS", null, null, null, null, null, null, null, null, null, null, null, 0xb0},
        {"BNE", null, null, null, null, null, null, null, null, null, null, null, 0xd0},
        {"BEQ", null, null, null, null, null, null, null, null, null, null, null, 0xf0},
        {"BRK", null, null, null, null, null, null, null, null, null, null, 0x00, null},
        {"CMP", 0xc9, 0xc5, 0xd5, null, 0xcd, 0xdd, 0xd9, null, 0xc1, 0xd1, null, null},
        {"CPX", 0xe0, 0xe4, null, null, 0xec, null, null, null, null, null, null, null},
        {"CPY", 0xc0, 0xc4, null, null, 0xcc, null, null, null, null, null, null, null},
        {"DEC", null, 0xc6, 0xd6, null, 0xce, 0xde, null, null, null, null, null, null},
        {"EOR", 0x49, 0x45, 0x55, null, 0x4d, 0x5d, 0x59, null, 0x41, 0x51, null, null},
        {"CLC", null, null, null, null, null, null, null, null, null, null, 0x18, null},
        {"SEC", null, null, null, null, null, null, null, null, null, null, 0x38, null},
        {"CLI", null, null, null, null, null, null, null, null, null, null, 0x58, null},
        {"SEI", null, null, null, null, null, null, null, null, null, null, 0x78, null},
        {"CLV", null, null, null, null, null, null, null, null, null, null, 0xb8, null},
        {"CLD", null, null, null, null, null, null, null, null, null, null, 0xd8, null},
        {"SED", null, null, null, null, null, null, null, null, null, null, 0xf8, null},
        {"INC", null, 0xe6, 0xf6, null, 0xee, 0xfe, null, null, null, null, null, null},
        {"JMP", null, null, null, null, 0x4c, null, null, 0x6c, null, null, null, null},
        {"JSR", null, null, null, null, 0x20, null, null, null, null, null, null, null},
        {"LDA", 0xa9, 0xa5, 0xb5, null, 0xad, 0xbd, 0xb9, null, 0xa1, 0xb1, null, null},
        {"LDX", 0xa2, 0xa6, null, 0xb6, 0xae, null, 0xbe, null, null, null, null, null},
        {"LDY", 0xa0, 0xa4, 0xb4, null, 0xac, 0xbc, null, null, null, null, null, null},
        {"LSR", null, 0x46, 0x56, null, 0x4e, 0x5e, null, null, null, null, 0x4a, null},
        {"NOP", null, null, null, null, null, null, null, null, null, null, 0xea, null},
        {"ORA", 0x09, 0x05, 0x15, null, 0x0d, 0x1d, 0x19, null, 0x01, 0x11, null, null},
        {"TAX", null, null, null, null, null, null, null, null, null, null, 0xaa, null},
        {"TXA", null, null, null, null, null, null, null, null, null, null, 0x8a, null},
        {"DEX", null, null, null, null, null, null, null, null, null, null, 0xca, null},
        {"INX", null, null, null, null, null, null, null, null, null, null, 0xe8, null},
        {"TAY", null, null, null, null, null, null, null, null, null, null, 0xa8, null},
        {"TYA", null, null, null, null, null, null, null, null, null, null, 0x98, null},
        {"DEY", null, null, null, null, null, null, null, null, null, null, 0x88, null},
        {"INY", null, null, null, null, null, null, null, null, null, null, 0xc8, null},
        {"ROR", null, 0x66, 0x76, null, 0x6e, 0x7e, null, null, null, null, 0x6a, null},
        {"ROL", null, 0x26, 0x36, null, 0x2e, 0x3e, null, null, null, null, 0x2a, null},
        {"RTI", null, null, null, null, null, null, null, null, null, null, 0x40, null},
        {"RTS", null, null, null, null, null, null, null, null, null, null, 0x60, null},
        {"SBC", 0xe9, 0xe5, 0xf5, null, 0xed, 0xfd, 0xf9, null, 0xe1, 0xf1, null, null},
        {"STA", null, 0x85, 0x95, null, 0x8d, 0x9d, 0x99, null, 0x81, 0x91, null, null},
        {"TXS", null, null, null, null, null, null, null, null, null, null, 0x9a, null},
        {"TSX", null, null, null, null, null, null, null, null, null, null, 0xba, null},
        {"PHA", null, null, null, null, null, null, null, null, null, null, 0x48, null},
        {"PLA", null, null, null, null, null, null, null, null, null, null, 0x68, null},
        {"PHP", null, null, null, null, null, null, null, null, null, null, 0x08, null},
        {"PLP", null, null, null, null, null, null, null, null, null, null, 0x28, null},
        {"STX", null, 0x86, null, 0x96, 0x8e, null, null, null, null, null, null, null},
        {"STY", null, 0x84, 0x94, null, 0x8c, null, null, null, null, null, null, null}
    };

    // Assembly methods

    // add byte to assembled code.
    private static void asmAddByte(int v) {
        //System.out.printf("%x%n", (v & 0xff));
        asm.add((byte)(v & 0xff));
        //System.out.println("Added byte...");
        PC++;
    }

    // add word to assembled code.
    private static void asmAddWord(int v) {
        //System.out.printf("%x %x%n", (v & 0xff), ((v & 0xff00) >>>8));
        asm.add((byte)(v & 0xff));
        asm.add((byte)((v & 0xff00) >>> 8));
        //System.out.println("Added word...");
        PC=PC+2;
    }

    // Utility methods

    // Show symbol table contents.
    private static void dumpSymtab(HashMap<String, String> symtab) {
        System.out.println("symtab:");
        for (Map.Entry<String, String> entry : symtab.entrySet()) {
            int v = tryParseWord(entry.getValue(), null);

            System.out.printf("%s\t$%x%n", entry.getKey(), v);
        }
    }

    // remove comment and exterior whitespace.
    private static String strip (String line) {
        int pos = line.indexOf(';');
        if ( pos != -1 )
            line = line.substring(0, pos);
        return line.trim();
    }

    // Methods for pseudo-ops

    // define constant byte
    public static boolean dcb(String param) {
        if (param.isEmpty())
            return true;

        String[] parts = param.split("\\s*,\\s*");
        for ( String n : parts ) {
            //System.out.println("dcb: doing " + n);
            int v = tryParseByte(n, null);
            if (v == -1)
                return false;
            asmAddByte(v);
        }
        return true;
    }

    // define constant word
    public static boolean dcw(String param) {
        if (param.isEmpty())
            return true;

        String[] parts = param.split("\\s*,\\s*m");
        for ( String n : parts ) {
            //System.out.println("dcw: doing " + n);
            int v = tryParseWord(n, null);
            if (v == -1)
                return false;
            asmAddWord(v);
        }
        return true;
    }

    // define storage byte - initialized to zero
    public static boolean dsb(String param, int m) {
        if (param.isEmpty())
            return true;

        int n;
        if ( (n = tryParseByte(param, null)) == -1 )
            return false;
        for (int x=0; x < n*m; x++)
            asmAddByte(0);
        return true;
    }

    // text literals
    public static boolean txt (String param) {
        Pattern p = Pattern.compile("^\"(.*)\"$");
        Matcher m;

        if (param.isEmpty())
            return true;

        m = p.matcher(param);
        if ( ! m.matches() )
            return false;

        String c = m.group(1);
        //System.out.println("txt: *"+c+"*");
        for (int x = 0; x<c.length(); x++) {
            //System.out.println("txt: doing " + c.charAt(x));
            asmAddByte(c.charAt(x));
        }

        return true;
    }

    // Methods to try various addressing modes.

    private static boolean checkSingle(String param, int o) {
        // do we bother?
        Object op = Opcodes[o][11];
        if ( op == null )
            return false;
        //String inst = (String)Opcodes[o][0];

        //System.out.println("checkSingle: "+inst+":"+param);
        // check param
        if ( param != null && !param.isEmpty())
            return false;

        //System.out.println("checkSingle: adding " + inst);
        // add instruction
        asmAddByte((int)op);
        return true;
    }

    private static boolean checkImmediate(String param, int o, HashMap<String, String> symtab) {
        // do we bother?
        Object op = Opcodes[o][1];
        if (op == null)
            return false;
        // maybe immediate?
        Pattern p = Pattern.compile("^#([<>]?)(\\$?\\w+)$");
        Matcher m = p.matcher(param);
        if (!m.matches())
            return false;
        // get the parts
        String l = m.group(1), r = m.group(2);
        //System.out.println("checkImmediate: group1: " + l + " group 2: " + r);
        //String inst = (String)Opcodes[o][0];
        //System.out.println("checkImmediate: "+inst+":"+param);

        // convert
        int i = tryParseWord(r, symtab);
        if ( i == -1 ) {
            asmAddWord(0); // forward label
            return false;
        }
        // process lo/hi byte operator
        if ( l != null && !l.isEmpty()) {
            if (l.charAt(0) == '>')
                i = (i & 0xff00) >>> 8;
            else
                i = i & 0xff;
        }
        asmAddByte((int)op);
        asmAddByte(i);
        return true;
    }
    private static boolean checkZeroPageXY(String param, int o, HashMap<String, String> symtab) {
        // do we bother?
        Object op = Opcodes[o][2], opx = Opcodes[o][3], opy = Opcodes[o][4], fin;
        if (op == null && opx == null && opy == null)
            return false;

        // Maybe...
        Pattern p = Pattern.compile("^(\\$?\\w+)(\\+\\d{1,2})?(,[XY])?$");
        Matcher m = p.matcher(param);
        if (!m.matches())
            return false;

        // get the parts
        String l = m.group(1), c = m.group(2), r = m.group(3);
        //System.out.println("checkZeroPageXY: group1: " + l + " group 2: " + c + " group 3: " + r);
        // zero page?
        int i = tryParseByte(l, symtab);
        if ( i == -1 )
            return false;
        // additive
        int a=0;
        if ( c != null )
            a = tryParseByte(c.substring(1), null);
        // fake add in case it's a forward label
        if (a == -1) {
            //asmAddByte(0xff);
            asmAddWord(0xffff);
            return false;
        }
        // which opcode?
        fin = op;
        if ( r != null && !r.isEmpty())
            fin = (r.charAt(1) == 'X') ? opx : opy;

        if ( fin == null )
            return false;
        asmAddByte((int)fin);
        asmAddByte(i+a); // this could overflow!
        return true;
    }

    private static boolean checkAbsoluteXY(String param, int o, HashMap<String, String> symtab) {
        // do we bother?
        Object op = Opcodes[o][5], opx = Opcodes[o][6], opy = Opcodes[o][7], fin;
        if (op == null && opx == null && opy == null)
            return false;

        // Maybe...
        Pattern p = Pattern.compile("^(\\$?\\w+)(\\+\\d{1,3})?(,[XY])?$");
        Matcher m = p.matcher(param);
        if (!m.matches())
            return false;

        // get the parts
        String l = m.group(1), c = m.group(2), r = m.group(3);
        //System.out.println("checkAbsoluteXY: group1: " + l + " group 2: " + c + " group 3: " + r);
        // address?
        int i = tryParseWord(l, symtab);

        // additive
        int a=0;
        if ( c != null )
            a = tryParseByte(c.substring(1), null);
        // fake add in case it's a forward label
        if ( i == -1 || a == -1 ) {
            asmAddByte(0xff);
            asmAddWord(0xffff);
            return false;
        }
        // which opcode?
        fin = op;
        if ( r != null && !r.isEmpty())
            fin = (r.charAt(1) == 'X') ? opx : opy;

        if ( fin == null )
            return false;
        //System.out.println("checkAbsoluteXY: " + fin + " " + i);
        asmAddByte((int)fin);
        asmAddWord(i+a);
        return true;
    }

    private static boolean checkIndirectXY(String param, int o, HashMap<String, String> symtab) {
        // do we bother?
        Object op = Opcodes[o][8], opx = Opcodes[o][9], opy = Opcodes[o][10], fin;
        if (op == null && opx == null && opy == null)
            return false;

        // Maybe...
        Pattern p = Pattern.compile("^\\((\\$?\\w+)(,X\\)|\\),Y)$");
        Matcher m = p.matcher(param);
        if (!m.matches())
            return false;

        // get the parts
        String l = m.group(1), r = m.group(2);
        //System.out.println("checkIndirectXY: group1: " + l + " group 2: " + r);
        // address?
        int i = tryParseByte(l, symtab);
        if ( i == -1 )
            return false;

        // which opcode?
        fin = op;
        if ( r != null && !r.isEmpty())
            fin = (r.charAt(1) == 'X') ? opx : opy;
        if ( fin == null ) return false;

        asmAddByte((int)fin);
        asmAddByte(i);
        return true;
    }

    private static boolean checkBranch(String param, int o, HashMap<String, String> symtab) {
        // do we bother?
        Object op = Opcodes[o][12];
        if (op == null)
            return false;

        // maybe
        Pattern p = Pattern.compile("^(\\$?\\w+)$");
        Matcher m = p.matcher(param);
        if (!m.matches())
            return false;

        // get the parts
        String l = m.group(1);
        //System.out.println("checkBranch: group1: " + l);
        // address?
        int i = tryParseWord(l, symtab);
        if ( i == -1 ) {
            asmAddWord(0);  // pad for pass 1
            return false;
        }
        asmAddByte((int)op);
        asmAddByte(i - PC - 1);
        return true;
    }

    private static void preprocess(String[] prg, HashMap<String,String> symtab) {
        for ( int x = 0; x < prg.length; x++ ) {
            String line = strip(prg[x]);
            // Start of program - only one start is allowed.
            if (line.matches("^\\*=\\s*\\$?\\w+$")) {
                String addr = strip(line.split("=")[1]);
                START = tryParseWord(addr, null);
                PC = START;
                prg[x]="";
            }
            // define statement
            else if (line.matches("^(?i)define\\s+\\w+\\s+\\S+$")) {
                String[] parts = line.split("\\s+");
                symtab.put(parts[1].toUpperCase(), parts[2]);
                prg[x]="";
            }
            // any other issues belong to passes 1 & 2!
        }
    }

    private static int tryParseByte(String n, HashMap<String, String> symtab) {
        String v;

        if ( n.matches("^\\$[a-fA-F0-9]{1,2}|[0-9]{1,3}$"))
            v = n;
        else if ( symtab != null && n.matches("^\\w+$") ) {
            v = symtab.get(n);
            if (v == null) return -1;
        } else return -1;
        //System.out.println("here! " + v);
        int i;
        try {
            if (v.charAt(0) == '$')
                i = Integer.parseInt(v.substring(1), 16);
            else
                i = Integer.parseInt(v);
            //System.out.println("tryParseByte: i is " + i);
        } catch (NumberFormatException e) {
            return -1;
        }
        if ( i >= 0 && i <= 255)
            return i;
        else return -1;
    }

    private static int tryParseWord(String n, HashMap<String, String> symtab) {
        String v;

        if ( n.matches("^\\$[a-fA-F0-9]{1,4}|[0-9]{1,5}$"))
            v = n;
        else if ( symtab != null && n.matches("^\\w+$") ) {
            v = symtab.get(n);
            //System.out.println("tryParseWord: n,v " + n + " " + v);
            if (v == null) return -1;
        } else return -1;
        //System.out.println("word here " + v);
        int i;
        try {
            if (v.charAt(0) == '$')
                i = Integer.parseInt(v.substring(1), 16);
            else
                i = Integer.parseInt(v);
            //System.out.println("tryParseWord: " + i);
        } catch (NumberFormatException e) {
            return -1;
        }
        if ( i >= 0 && i <= 65535)
            return i;
        else return -1;
    }

    private static boolean assembleLine(String oline, int lineNum, HashMap<String,String> symtab) {
        Pattern p1 = Pattern.compile(lblOpRegex);
        Matcher m1;
        String /*label,*/ command, param;

        ERROR = lineNum != 0;

        String line = strip(oline);
        // blank line
        if (line.isEmpty())
            return true;

        // what do we have here?
        m1 = p1.matcher(line);
        if ( m1.matches() ) {
            //label = m1.group(1);
            command = m1.group(2).toUpperCase();
            param = m1.group(3).toUpperCase().trim();
        } else return false;

        //System.out.println("label = " + label + " command = " + command + " param = " + param);

        // pseudo ops.
        switch (command) {
            case "DCB" -> {
                return dcb(param);
            }
            case "DCW" -> {
                return dcw(param);
            }
            case "DSB" -> {
                return dsb(param, 1);
            }
            case "DSQ" -> {
                return dsb(param, 2);
            }
            case "TXT" -> {
                return txt(param);
            }
        }

        // if not a pseudo op, let's reshape param.
        param = param.replaceAll("\\s","");

        // do op.
        int o;
        for (o = 0; o < Opcodes.length; o++)
            if (command.equals(Opcodes[o][0]))
                break;

        // valid opcode?
        if ( o >= Opcodes.length) {
            if (ERROR)
                System.out.println("Line " + lineNum + ": " + oline + "\nIllegal opcode: " + command);
            return false;
        }

        // check all the addressing modes.
        if ( checkSingle(param, o) ) return true;
        if ( checkImmediate(param, o, symtab) ) return true;
        if ( checkZeroPageXY(param, o, symtab) ) return true;
        if ( checkAbsoluteXY(param, o, symtab) ) return true;
        if ( checkIndirectXY(param, o, symtab) ) return true;
        if ( checkBranch(param, o, symtab) ) return true;

        if ( ERROR )
            System.out.println("Line " + lineNum + ": " + oline + "\nIllegal addressing mode.");
        return false;
    }

    private static void collectLabels(String[] prg, HashMap<String,String> symtab) {
        Pattern p = Pattern.compile("^\\s*(\\w+)\\s*:(.*)?$");
        Matcher m;

        for (String s : prg) {
            String line = strip(s);

            if (line.isEmpty())
                continue;
            // add label
            m = p.matcher(line);
            if (m.matches())
                symtab.put(m.group(1).toUpperCase(), Integer.toString(PC));
            assembleLine(line.trim(), 0, symtab);
        }
    }
    private static byte[] assembleProgram(String[] prg) {
        HashMap<String,String> symtab = new HashMap<>();

        int x;
        /* PASS 0 - find preprocessor directives. */
        System.out.println("Preprocessing...");
        preprocess(prg, symtab);
        //System.out.println("PC = " + PC + "\nSymtab:\n" + symtab); //debug

        /* PASS 1 - find labels and build symbol table. */
        System.out.println("Pass 1: calculating labels...");
        collectLabels(prg, symtab);
        //System.out.println("PC = " + PC); //debug
        //dumpSymtab(symtab); // debug
        //dumpAsm(); //debug

        /* PASS 2 - generate code */
        System.out.println("Pass 2: assembling program...");
        PC = START;
        asm = new ArrayList<>();
        for (x = 0; x < prg.length; x++) {
            if ( !assembleLine(prg[x], x+1, symtab) ) {
                System.out.println("line " + (x+1) + ": " + prg[x]);
                System.out.println("Syntax error.");
                return null;
            }
        }

        //System.out.println("PC = " + PC);
        dumpSymtab(symtab); //debug
        //dumpAsm(); //bug

        int size = asm.size();
        byte[] ba = new byte[size];
        x=0;
        for (Byte b : asm) {
            ba[x] = b;
            x++;
        }
        return ba;
    }

    public static void main(String[] args) throws IOException {
        Scanner inFile=null;

        try {
            inFile = new Scanner(new File(args[0]));
        } catch (FileNotFoundException e) {
            System.out.println("Cannot open input file. Terminating.");
            System.exit(1);
        }

        // Read the file!
        ArrayList<String> lines = new ArrayList<>();
        while (inFile.hasNext()) {
            lines.add(inFile.nextLine());
        }
        inFile.close();

        // Fixup OPS regexes.
        StringBuilder replace = new StringBuilder((String) Opcodes[0][0]);
        for ( int x = 1; x < Opcodes.length-1; x++)
            replace.append("|").append(Opcodes[x][0]);
        lblOpRegex = lblOpRegex.replaceAll("OPS", replace.toString());
        //System.out.println(lblOpRegex); //debug

        // Assemble the program!
        byte[] obj = assembleProgram(lines.toArray(new String[0]));

        // Write the program out as a stream of bytes!
        if (obj != null) {
            FileOutputStream out = new FileOutputStream(args[1]);
            // programs have first two bytes as load address
            out.write((byte)(START & 0xff));
            out.write((byte)((START & 0xff00) >>> 8));
            out.write(obj);
            out.close();

            int size = PC - START;
            System.out.println("\nAssembled to " + size + " bytes.\nWrote " + obj.length + " bytes.");
        }
    }
}
