const fs = require("fs");
const { spawnSync } = require("child_process");

const [exec, scriptName, workingDir] = process.argv;

if (!fs.existsSync(workingDir)) {
  throw new Error("Working directory doesn't exist: " + workingDir);
}
process.chdir(workingDir);
if (!fs.existsSync("SHASUMS256.txt")) {
  throw new Error("No SHASUMS256.txt to override in folder: " + workingDir);
}

// 1. read shasums file
const shaSums = fs
  .readFileSync("SHASUMS256.txt")
  .toString()
  .trim()
  .split("\n")
  .reduce((hashes, line) => {
    const [file, hash] = line.split(/\s+/);
    hashes[file] = hash;
    return hashes;
  });

// 2. generate new shas
const files = fs
  .readdirSync(".", { withFileTypes: true })
  .filter((e) => e.isFile() && e.name !== "SHASUMS256.txt")
  .map((e) => e.name);

const proc = spawnSync("shasum", ["-a", "256", ...files]);

if (proc.stderr.length) {
  console.error(proc.stderr.toString());
  process.exit(1);
}

const shasumOutput = proc.stdout.toString();
newHashes = shasumOutput.trim().split("\n");

// 2. replace old ones
newHashes.forEach(([fileName, hash]) => {
  shaSums[fileName] = hash;
});

// 3. write shasums256.txt
const fileContent = Object.keys(shaSums).reduce((output, fileName) => {
  output += `${shaSums[fileName]}\t${fileName}`;
  return output;
}, "");

fs.writeFileSync("SHASUMS256.txt", fileContent);
