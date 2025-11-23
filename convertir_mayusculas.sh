#!/bin/bash

# Este script convierte solo la primera parte (el nombre del servicio)
# del archivo *.yml a MAYÚSCULAS, dejando el sufijo del perfil intacto.
# Ejemplo: user-service-dev.yml -> USER-SERVICE-dev.yml

echo "Iniciando el cambio de nombre de la parte del servicio a MAYÚSCULAS..."
echo "----------------------------------------------------------------------"

# Bucle para procesar todos los archivos .yml
for file in *.yml; do
    if [[ -f "$file" ]] && [[ "$file" != "application.yml" ]]; then
        
        # 1. Extraer el nombre del servicio (todo antes del primer guion)
        service_name=$(echo "$file" | cut -d'-' -f1)
        
        # 2. Extraer el sufijo del perfil (todo después del primer guion)
        profile_suffix=$(echo "$file" | cut -d'-' -f2-)
        
        # 3. Convertir solo el nombre del servicio a mayúsculas
        upper_service_name="${service_name^^}"
        
        # 4. Construir el nuevo nombre del archivo
        new_file="${upper_service_name}-${profile_suffix}"
        
        # 5. Verificar y renombrar
        if [[ "$file" != "$new_file" ]]; then
            echo "Renombrando: $file -> $new_file"
            mv "$file" "$new_file"
        else
            echo "Saltando: $file (ya está en el formato correcto)"
        fi
    fi
done

# Manejo especial para application.yml (si deseas renombrarlo a APPLICATION.yml)
if [[ -f "application.yml" ]]; then
    mv "application.yml" "APPLICATION.yml" 2>/dev/null
    echo "Renombrando application.yml -> APPLICATION.yml"
fi

echo "----------------------------------------------------------------------"
echo "Proceso completado. Revisa los nombres de los archivos."