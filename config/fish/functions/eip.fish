# Defined in - @ line 1
function eip --wraps=ip\ addr\ show\ label\ \'enp\*\'\ \|\ grep\ \'inet\'\ \|\ grep\ -v\ \'inet6\'\ \|\ awk\ \'\{print\ \}\' --description alias\ eip=ip\ addr\ show\ label\ \'enp\*\'\ \|\ grep\ \'inet\'\ \|\ grep\ -v\ \'inet6\'\ \|\ awk\ \'\{print\ \}\'
  ip addr show label 'enp*' | grep 'inet' | grep -v 'inet6' | awk '{print $2}' $argv;
end
