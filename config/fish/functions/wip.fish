# Defined in - @ line 1
function wip --wraps=ip\ addr\ show\ label\ \'wlp\*\'\ \|\ grep\ \'inet\'\ \|\ grep\ -v\ \'inet6\'\ \|\ awk\ \'\{print\ \}\' --description alias\ wip=ip\ addr\ show\ label\ \'wlp\*\'\ \|\ grep\ \'inet\'\ \|\ grep\ -v\ \'inet6\'\ \|\ awk\ \'\{print\ \}\'
  ip addr show label 'wlp*' | grep 'inet' | grep -v 'inet6' | awk '{print $2}' $argv;
end
