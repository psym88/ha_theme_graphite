// Checks the three files a Home Assistant install reads against each other:
// hacs.json for the Marketplace, the theme file itself, and the README the
// Marketplace page shows. Run it before committing, and on every push.
//
//   GITHUB_DISTRIBUTION_REPOSITORY=psym88/ha_theme_graphite node scripts/check-theme.mjs
import fs from "node:fs";
import path from "node:path";

const root = path.dirname(path.dirname(fs.realpathSync(import.meta.filename)));
const problems = [];
const read = (file) => fs.readFileSync(path.join(root, file), "utf8");
const exists = (file) => fs.existsSync(path.join(root, file));

let manifest;
try {
  manifest = JSON.parse(read("hacs.json"));
} catch (error) {
  console.error(`hacs.json does not read as JSON: ${error.message}`);
  process.exit(1);
}

const themeName = manifest.name;
const fileName = manifest.filename;

if (typeof themeName !== "string" || themeName.trim() === "") {
  problems.push("hacs.json has no name, the Marketplace would show an empty entry.");
}
if (typeof fileName !== "string" || !/\.ya?ml$/.test(fileName)) {
  problems.push(`hacs.json has no filename ending in .yaml, it says ${JSON.stringify(fileName)}.`);
}

const themePath = `themes/${fileName}`;
if (!exists(themePath)) {
  problems.push(`${themePath} is not in the repository, so neither HACS nor the release asset can find it.`);
}

if (exists(themePath)) {
  const theme = read(themePath);
  const lines = theme.split("\n");

  if (theme.trim() === "") {
    problems.push(`${themePath} is empty.`);
  }
  if (lines.some((line) => /^\t/.test(line))) {
    problems.push(`${themePath} indents with a tab, which YAML does not allow.`);
  }

  // Home Assistant lists the theme under the top level key of this file, the
  // Marketplace lists it under the name in hacs.json. Two names, two entries.
  const topLevel = lines.find((line) => /^[^\s#][^:]*:\s*$/.test(line));
  const expected = `${themeName}:`;
  if (topLevel === undefined) {
    problems.push(`${themePath} has no top level key, so Home Assistant has no theme to offer.`);
  } else if (themeName && topLevel.trim() !== expected) {
    problems.push(
      `${themePath} opens with ${topLevel.trim()} while hacs.json calls the theme ${themeName}.`,
    );
  }
}

// The README is what the Marketplace page renders: a link that opens a repository
// that is not there, or a picture that was deleted, is what a visitor sees first.
const readme = read("README.md");
const distribution = process.env.GITHUB_DISTRIBUTION_REPOSITORY;
if (!distribution) {
  console.error("GITHUB_DISTRIBUTION_REPOSITORY is not set, so the README link was not checked.");
  process.exit(1);
}
const [owner, repository] = distribution.split("/");
const badge = `https://my.home-assistant.io/redirect/hacs_repository/?owner=${owner}&repository=${repository}&category=theme`;
if (!readme.includes(badge)) {
  problems.push(`README.md has no Marketplace badge for ${distribution}, it should carry ${badge}`);
}

for (const link of readme.matchAll(/!\[[^\]]*\]\(([^)]+)\)/g)) {
  const target = link[1].trim();
  if (/^https?:/.test(target)) continue;
  if (!exists(target.split("#")[0])) {
    problems.push(`README.md shows ${target}, which is not in the repository.`);
  }
}

if (problems.length > 0) {
  for (const problem of problems) console.error(`- ${problem}`);
  process.exit(1);
}

console.log(`${themeName} reads from ${themePath}, the README points at ${distribution}.`);
