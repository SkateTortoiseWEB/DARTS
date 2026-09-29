P=${1:-$(cd "$(dirname "$0")/../.." && pwd)/Oche.app/Contents/Resources/oche.html}
cd "$(dirname "$0")"
for c in '{"seed":3,"turns":6}' '{"seed":5,"turns":6,"gap":700}' '{"seed":21,"turns":6,"gap":500}' '{"seed":11,"turns":6,"magR":5,"noise":14}' '{"seed":9,"turns":6,"magCol":"#9a9a9a","hi":"#e0e0e0"}' '{"seed":3,"turns":6,"magCol":"#d42a2a","hi":"#ff8080"}' '{"seed":13,"turns":6,"group":15}' '{"seed":17,"turns":6,"group":15,"magCol":"#d42a2a","hi":"#ff8080"}'; do
  printf '%-70s ' "$c"; timeout 400 node run.mjs $P "$c" | tail -1 | sed 's/RESULT //'; done
