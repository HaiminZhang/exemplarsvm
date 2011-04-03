function dump_turk_cows;
VOCinit;

resdir = '/nfs/baikal/tmalisie/turk/';
cls = 'cow';
asp = 'Right';
fg = get_pascal_bg('trainval',cls);

files = cell(0,1);
for i = 1:length(fg)
  [tmp,curid,tmp] = fileparts(fg{i});
  recs = PASreadrecord(sprintf(VOCopts.annopath,curid));  
  Ibase = imread(sprintf(VOCopts.imgpath,curid));
  Ibase = im2double(Ibase);
  c = {recs.objects.class};
  bbs = cat(1,recs.objects.bbox);
  goods = find(ismember(c,{cls}));
  for j = 1:length(goods)
    b = bbs(goods(j),:);
    
    if (recs.objects(goods(j)).difficult | recs.objects(goods(j)).truncated ...
        | recs.objects(goods(j)).difficult)
      continue
    end
    
    
    if ~strcmp(recs.objects(goods(j)).view,asp)
      continue
    end

    files{end+1}=sprintf('"http://balaton.graphics.cs.cmu.edu/tmalisie/memex/turk/%s.%05d.png"',curid,goods(j));
    
    W = .2*(b(4) -b(2) +1);
    H = .2*(b(3) -b(1) +1);
    b(1) = b(1) - H;
    b(3) = b(3) + H;
    b(2) = b(2) - W;
    b(4) = b(4) + W;
    b = round(b);
    b = clip_to_image(b,[1 1 size(Ibase,2) size(Ibase,1)]);
    
    subI = Ibase(b(2):b(4),b(1):b(3),:);
    factor = 200/max(size(subI,2),size(subI,1));
    subI = max(0.0,min(1.0,imresize(subI,factor)));
    imwrite(subI,sprintf('%s/%s.%05d.png',resdir,curid,goods(j)));
  end
  %drawnow
  %2pause(.1)
  
  
  
end

filer = fopen(sprintf('~/www/turank/%s.%s.js',cls,asp),'w');
fprintf(filer,'var items = [');
for i = 1:(length(files)-1)
  fprintf(filer,'%s,\n',files{i});
end
fprintf(filer,'%s]',files{end});