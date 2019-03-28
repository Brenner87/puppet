define django::update_pip (
    $python
){
    exec {'update-pip':
        command => "/bin//${python} -m pip install -U pip"
}
