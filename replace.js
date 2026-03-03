const fs = require('fs');
const path = require('path');

function walk(dir) {
    fs.readdirSync(dir).forEach(file => {
        const fullPath = path.join(dir, file);
        if (fs.statSync(fullPath).isDirectory()) {
            walk(fullPath);
        } else if (fullPath.endsWith('.dart')) {
            const orig = fs.readFileSync(fullPath, 'utf8');
            let modified = orig;
            // 1. .withOpacity(x) -> .withValues(alpha: x)
            modified = modified.replace(/\.withOpacity\(([^)]+)\)/g, '.withValues(alpha: $1)');
            // 2. ?? 'string' -> remove it (when it is following l10n.translate)
            modified = modified.replace(/(l10n\.translate\([^)]+\))\s*\?\?\s*'[^']*'/g, '$1');
            modified = modified.replace(/(l10n\.translate\([^)]+\))\s*\?\?\s*"[^"]*"/g, '$1');
            // 3. _NavBarLink -> _navBarLink
            modified = modified.replace(/_NavBarLink/g, '_navBarLink');

            // 4. Also replace _ThemeSelector if it is not camel case (if any)
            // just check if we changed anything
            if (orig !== modified) {
                fs.writeFileSync(fullPath, modified, 'utf8');
                console.log(`Updated ${fullPath}`);
            }
        }
    });
}

walk('lib');
console.log('Done');
