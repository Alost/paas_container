import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

public class Main {
    public static void main(String[] args) throws Exception {
        Path jarDir = Paths.get(Main.class.getProtectionDomain()
                .getCodeSource().getLocation().toURI()).getParent();
        Path script = jarDir.resolve("start.sh");

        List<String> cmd = new ArrayList<>();
        cmd.add("/usr/bin/env");
        cmd.add("env");
        cmd.add("bash");
        if (script.toFile().exists()) {
            cmd.add(script.toString());
        } else {
            cmd.add("-i");
        }
        cmd.addAll(Arrays.asList(args));

        Process p = new ProcessBuilder(cmd)
                .inheritIO()
                .start();
        System.exit(p.waitFor());
    }
}
