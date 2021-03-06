#!/bin/bash
#Note users will require a github account and need to have virtualenv installed

setup(){

  #First make a directory in which simulation data and programs will be kept
  mkdir ./Simulation



  cd Simulation


  #Install RSEM
  wget https://github.com/deweylab/RSEM/archive/v1.3.0.tar.gz
  tar -xvzf v1.3.0.tar.gz
  rm v1.3.0.tar.gz
  cd RSEM-1.3.0
  make
  make install prefix=.
  cd ..
  if ! command -v ./RSEM-1.3.0/rsem-generate-data-matrix >/dev/null 2>&1; then
    echo "Failed to install RSEM"
    exit 1
  else
    echo "Successfully installed RSEM"
  fi

  #Install Sailfish
  wget https://github.com/kingsfordgroup/sailfish/releases/download/v0.10.0/SailfishBeta-0.10.0_CentOS5.tar.gz
  tar -xvzf SailfishBeta-0.10.0_CentOS5.tar.gz
  rm SailfishBeta-0.10.0_CentOS5.tar.gz
  export LD_LIBRARY_PATH=`pwd`/SailfishBeta-0.10.0_CentOS5/lib:$LD_LIBRARY_PATH
  export PATH=`pwd`/SailfishBeta-0.10.0_CentOS5/bin:$PATH
  if ! command -v ./SailfishBeta-0.10.0_CentOS5/bin/sailfish -h; then
    echo "Failed to install Sailfish"
    exit 1
  else
    echo "Successfully installed Sailfish"
  fi

  #Install eXpress
  wget https://pachterlab.github.io/eXpress/downloads/express-1.5.1/express-1.5.1-linux_x86_64.tgz
  tar -xvzf express-1.5.1-linux_x86_64.tgz
  rm express-1.5.1-linux_x86_64.tgz
  if ! command -v ./express-1.5.1-linux_x86_64/express >/dev/null 2>&1; then
    echo "Failed to install eXpress"
    exit 1
  else
    echo "Successfully installed eXpress"
  fi

  #Install Salmon
  wget https://github.com/COMBINE-lab/salmon/releases/download/v0.8.2/Salmon-0.8.2_linux_x86_64.tar.gz
  tar -xvzf Salmon-0.8.2_linux_x86_64.tar.gz
  rm Salmon-0.8.2_linux_x86_64.tar.gz
  if ! command -v ./Salmon-0.8.2_linux_x86_64/bin/salmon >/dev/null 2>&1; then
    echo "Failed to install Salmon"
    exit 1
  else
    echo "Successfully installed Salmon"
  fi

  #Install Kallisto
  wget https://github.com/pachterlab/kallisto/releases/download/v0.43.1/kallisto_linux-v0.43.1.tar.gz
  tar -xvzf kallisto_linux-v0.43.1.tar.gz
  rm kallisto_linux-v0.43.1.tar.gz
  if ! command -v ./kallisto_linux-v0.43.1/kallisto >/dev/null 2>&1; then
    echo "Failed to install Kallisto"
    exit 1
  else
    echo "Successfully installed Kallisto"
  fi

  #Install STAR
  git clone https://github.com/alexdobin/STAR.git
  if ! command -v ./STAR/bin/Linux_x86_64/STAR >/dev/null 2>&1; then
    echo "Failed to install STAR"
    exit 1
  else
    echo "Successfully installed STAR"
  fi

  #Install samtools
  wget https://github.com/samtools/samtools/releases/download/1.5/samtools-1.5.tar.bz2
  bzip2 -d samtools-1.5.tar.bz2
  tar -xvf samtools-1.5.tar
  rm samtools-1.5.tar
  cd samtools-1.5/
  ./configure --prefix=`pwd`
  make
  make install
  cd ..
  if ! command -v ./samtools-1.5/samtools >/dev/null 2>&1; then
    echo "Failed to install SAMtools"
    exit 1
  else
    echo "Successfully installed SAMtools"
  fi

  #Install virtualenv and RSeQC
  git clone https://github.com/pypa/virtualenv.git
  python virtualenv/virtualenv.py venv
  source venv/bin/activate
  pip install RSeQC
  if ! command -v  >/dev/null 2>&1; then
    echo "Failed to install RSeQC"
    exit 1
  else
    echo "Successfully installed RSeQC"
  fi

  #Install cutadapt
  pip install cutadapt
  pip install bz2file

  #Install bbtools
  wget https://sourceforge.net/projects/bbmap/files/BBMap_37.50.tar.gz

  tar -xvzf BBMap_37.50.tar.gz

  #Make a directory for RNA-seq data including raw and simulated data
  mkdir data
  cd data
  mkdir simulated
  mkdir temp
  cd ..

  #Make a directory for quality control statistics for raw and simulated data
  mkdir QC_stats
  cd QC_stats
  mkdir raw
  mkdir simulated
  mkdir temp_raw
  mkdir temp_simulated
  cd ..

  mkdir indices
  mkdir indices/STAR
  mkdir indices/Salmon_SMEM
  mkdir indices/Salmon_quasi
  mkdir indices/Kallisto
  mkdir indices/Sailfish

  mkdir bamfiles
  mkdir bamfiles/raw
  mkdir bamfiles/simulated

  mkdir time_stats

  mkdir ref
  mkdir results_matrices

  cd ..
  mkdir figures/data
  mkdir figures/pngs
  mkdir figures/pdfs

  mkdir Polyester_Simulations
  cp -r * Polyester_Simulations

  mkdir ./ES_cell_data

  #Download single-cell (and bulk) data
  cd ES_cell_data
  cat ../urls.txt | xargs -n 1 -P 1 wget -t 100 -q

  mkdir software
  cd software
  wget https://ftp-trace.ncbi.nlm.nih.gov/sra/sdk/2.9.0/sratoolkit.2.9.0-ubuntu64.tar.gz
  tar -xvzf sratoolkit.2.9.0-ubuntu64.tar.gz

  wget https://github.com/FelixKrueger/TrimGalore/0.5.0.zip
  unzip 0.5.0.zip

  wget https://github.com/broadinstitute/picard/releases/download/2.18.0/picard.jar
  cd ..

  for i in *.sra;
  do
    ./software/sratoolkit.2.9.0-ubuntu64/bin/fastq-dump --split-3 $i
  done

  mkdir ../fastqc_trimmed_results

  for i in *_1.fastq;
  do
    filename=`echo $i | awk -F_ '{print $1}'`
    ./software/TrimGalore-0.5.0/trim_galore --nextera --paired -o ../fastqc_trimmed_results $filename"_1.fastq" $filename"_2.fastq"
  done

  cd ../fastqc_trimmed_results

  for i in *val*;
  do
    new_filename=`echo $i | awk -F_ '{print $1"_"$2".fastq"}'`
    mv $i $new_filename
  done

  cd ..

  rm -r ES_cell_data
  mv fastqc_trimmed_results ES_cell_data

}

"$@"
