conda activate qiime2-amplicon-2024.10

cd /users/valentinagirardi/downloads/SILVA138-REFNR99

# Descargar datos de SILVA
qiime rescript get-silva-data \
    --p-version '138.1' \
    --p-target 'SSURef_NR99' \
    --o-silva-sequences silva-138.1-ssu-nr99-rna-seqs.qza \
    --o-silva-taxonomy silva-138.1-ssu-nr99-tax.qza

# Convertir datos a FeatureData[Sequence]
qiime rescript reverse-transcribe \
    --i-rna-sequences silva-138.1-ssu-nr99-rna-seqs.qza \
    --o-dna-sequences silva-138.1-ssu-nr99-seqs.qza

# Eliminar secuencias de baja calidad
qiime rescript cull-seqs \
    --i-sequences silva-138.1-ssu-nr99-seqs.qza \
    --o-clean-sequences silva-138.1-ssu-nr99-seqs-cleaned.qza

# Filtrar secuencias por longitud y taxonomía
qiime rescript filter-seqs-length-by-taxon \
    --i-sequences silva-138.1-ssu-nr99-seqs-cleaned.qza \
    --i-taxonomy silva-138.1-ssu-nr99-tax.qza \
    --p-labels Archaea Bacteria Eukaryota \
    --p-min-lens 900 1200 1400 \
    --o-filtered-seqs silva-138.1-ssu-nr99-seqs-filt.qza \
    --o-discarded-seqs silva-138.1-ssu-nr99-seqs-discard.qza

# Eliminar redundancia en las secuencias
qiime rescript dereplicate \
    --i-sequences silva-138.1-ssu-nr99-seqs-filt.qza  \
    --i-taxa silva-138.1-ssu-nr99-tax.qza \
    --p-mode 'uniq' \
    --o-dereplicated-sequences silva-138.1-ssu-nr99-seqs-derep-uniq.qza \
    --o-dereplicated-taxa silva-138.1-ssu-nr99-tax-derep-uniq.qza

# Entrenar clasificador Naive Bayes
qiime feature-classifier fit-classifier-naive-bayes \
  --i-reference-reads silva-138.1-ssu-nr99-seqs-derep-uniq.qza \
  --i-reference-taxonomy silva-138.1-ssu-nr99-tax-derep-uniq.qza \
  --o-classifier silva-138.1-ssu-nr99-classifier.qza

# -----------------------------------------------------------------------
# AHORA SI QUIERO HACERLO SÓLO PARA LA REGIÓN V3-V4:
# Extraer la región V3-V4 usando primers específicos (son los de NOVOGENE)
qiime feature-classifier extract-reads \
    --i-sequences silva-138.1-ssu-nr99-seqs-derep-uniq.qza \
    --p-f-primer CCTAYGGGRBGCASCAG \
    --p-r-primer GGACTACNNGGGTATCTAAT \
    --p-min-length 300 \
    --p-max-length 600 \
    --o-reads silva-138.1-ssu-nr99-seqs-v3v4.qza

# Entrenar clasificador Naive Bayes con la región V3-V4
qiime feature-classifier fit-classifier-naive-bayes \
    --i-reference-reads silva-138.1-ssu-nr99-seqs-v3v4.qza \
    --i-reference-taxonomy silva-138.1-ssu-nr99-tax-derep-uniq.qza \
    --o-classifier silva-138.1-ssu-nr99-classifier-v3v4NOV.qza

# -----------------------------------------------------------------------
# Extraer la región V3-V4 usando primers específicos (son los de MACROGENE)
qiime feature-classifier extract-reads \
    --i-sequences silva-138.1-ssu-nr99-seqs-derep-uniq.qza \
    --p-f-primer CCTACGGGNGGCWGCAG \
    --p-r-primer GACTACHVGGGTATCTAATCC \
    --p-min-length 300 \
    --p-max-length 600 \
    --o-reads silva-138.1-ssu-nr99-seqs-v3v4M.qza

# Entrenar clasificador Naive Bayes con la región V3-V4
qiime feature-classifier fit-classifier-naive-bayes \
    --i-reference-reads silva-138.1-ssu-nr99-seqs-v3v4M.qza \
    --i-reference-taxonomy silva-138.1-ssu-nr99-tax-derep-uniq.qza \
    --o-classifier silva-138.1-ssu-nr99-classifier-v3v4MAC.qza
